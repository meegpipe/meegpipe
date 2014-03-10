function obj = add_source(obj, varargin)
% ADD_SOURCE - Adds an EEG source to an MRI-based head model
%
%
% obj = add_source(obj, 'key', value, ...)
%
%
% where
%
% OBJ is a head.mri object
%
%
% ## Accepted key/value pairs:
%
% 'Name'        : Name identifying the EEG source (a string)
%
% 'MinDepth'    : Minimum depth, in mm, of the EEG source. Default: 0
%
% 'MaxDepth'    : Maximum depth, in mm. Default: Inf
%
% 'Volume'      : A scalar specifying the number of dipoles that the EEG
%                 source contains. Default: 1
% 
% 'MinAngle'    : Minimum angle of the source dipole(s) forms with
%                 with the radial axis (in degrees). Default: 0
%
% 'MaxAngle'    : Maximum angle with the radial axis. Default: 90
%
% 'Angle'       : Angle with the radial axis (overrides MinAngle and
%                 MaxAngle) 
% 
% 'MinStrength' : Minimum strength of the source dipole(s). Default: 1
%
% 'MaxStrength' : Maximum strength of the source dipole(s). Default: 1
%
% 'Strength'    : Source strength. Overrides MinStrength and MaxStrength
%
%
% ## Notes:
%                
%   * The actual dipole angle will be randomly chosen between MinAngle and
%     MaxAngle
%
% See also: head.mri
%

% Description: Adds an EEG source
% Documentation: class_head_mri.txt

import misc.process_varargin;
import misc.euclidean_dist;

funcId = 'head:mri:add_source';

NotEnoughPoints = MException([funcId ':NotEnoughPoints'], ...
    'Not enough points fulfilling the criteria. Try using a finer source grid or less exigent criteria');

NoSourceSpace   = MException([funcId ':NoSourceSpace'], ...
    'Run make_source_grid() first!');

keySet = {'name', 'centroid', 'minvolume', 'maxvolume', ...
    'volume', 'mindepth', 'maxdepth', 'depth', 'minangle', 'maxangle', ...
    'angle', 'minstrength', 'maxstrength', 'strength', 'activation'};

name        = [];
centroid    = [];
minvolume   = 1;
maxvolume   = 1;
volume      = [];
mindepth    = 0; % In mm
maxdepth    = Inf;
depth       = [];
minangle    = 0;
maxangle    = 90;
angle       = [];
minstrength = 1;
maxstrength = 1;
strength    = [];
activation  = 1;
eval(process_varargin(keySet, varargin));

if ~isempty(volume),
    minvolume = volume;
    maxvolume = volume;
end

if ~isempty(depth),
    mindepth = depth;
    maxdepth = depth;
end

if ~isempty(angle),
    minangle = angle;
    maxangle = angle;
end

if ~isempty(strength),
    minstrength = strength;
    maxstrength = strength;
end

if isempty(obj.SourceSpace),
    throw(NoSourceSpace);
end


% Points that fullfil the depth constraints
validPoints = find(obj.SourceSpace.depth>=mindepth & obj.SourceSpace.depth<=maxdepth);

% Points that have not been already taken
alreadyPickedPoints = [];
for i = 1:numel(obj.Source)
   alreadyPickedPoints = [alreadyPickedPoints;obj.Source(i).pnt(:)];  %#ok<AGROW>
end

validPoints = setdiff(validPoints, alreadyPickedPoints);

% Randomize the source volume
volume = min(maxvolume, ceil(minvolume+(maxvolume-minvolume)*rand));

if numel(validPoints) < volume,
    throw(NotEnoughPoints);
end



selected = randperm(numel(validPoints));
pickedPoints = validPoints(selected(1));

dist = euclidean_dist(obj.SourceSpace.pnt(pickedPoints,:), obj.SourceSpace.pnt(validPoints, :));
[val,idx] = sort(dist,'ascend');
pickedPoints = validPoints(idx(1:volume));


% % Pick the dipoles for this source
% count = 0;
% allPoints    = setdiff(1:obj.NbSourceVoxels, alreadyPickedPoints);
% pickedPoints = nan(volume, 3);
% d = euclidean_dist(sourcePoints(allPoints,:), centroid);
% 
% while (count < volume && ~isempty(allPoints))
%     [~, index] = min(d);
%     thisDepth = head.mri.point_depth(surfPoints, sourcePoints(allPoints(index), :));    
%     if thisDepth >= mindepth && thisDepth <= maxdepth,
%         count = count + 1;
%         pickedPoints(count) = allPoints(index);        
%     end        
%     allPoints(index) = [];
%     d(index) = [];    
% end
% if count == 0 || minvolume > count,
%     throw(NotEnoughPoints);
% end
% pickedPoints = pickedPoints(1:count);
% sourcePoints = sourcePoints(pickedPoints,:);
% volume = count;

% Randomize the strengths of the source dipoles
strength = repmat(minstrength, volume, 1)+...
    (maxstrength-minstrength)*rand(volume,1);

% Necessary for the dipole angles
cmass       = mean(obj.InnerSkull.pnt);
nVert       = size(obj.InnerSkull.pnt,1);
surfPoints  = obj.InnerSkull.pnt - repmat(cmass, nVert,1);
sourcePoints= obj.SourceSpace.pnt - repmat(cmass, obj.NbSourceVoxels, 1);

sourcePoints = sourcePoints(pickedPoints,:);

% Randomize the dipole angles
m = sourcePoints./repmat(euclidean_dist(sourcePoints, [0 0 0]), 1, 3);
[tmp1, tmp2, tmp3] = cart2sph(m(:,1), m(:,2), m(:,3));
mSph = [tmp1 tmp2 tmp3];
mSph2 = mSph;
angleShift = repmat(minangle, volume, 1)+(maxangle-minangle)*rand(volume, 1);
angleShift = 2*pi*(angleShift/360);
mSph2(:,2) = mSph2(:,2)+angleShift;
[tmp1 tmp2 tmp3] = sph2cart(mSph2(:,1), mSph2(:,2), mSph2(:,3));
m2 = [tmp1 tmp2 tmp3];

momentum = repmat(strength,1,3).*m2;
% Create the source
if size(activation, 1) == 1,
    activation = repmat(activation, volume, 1);
end
source = struct('name', name, ...
    'strength', strength,...
    'orientation', m2, ...
    'angle', mod(360*(angleShift/(2*pi)), 360), ...
    'pnt', pickedPoints, ...
    'momentum', momentum, ...
    'activation', activation, ...
    'depth', obj.SourceSpace.depth(pickedPoints));

check_sources(obj);

if isempty(obj.Source),
    obj.Source = source;
else
    obj.Source(end+1) = source;
end

% Rebuild the source leadfield
if ~isempty(obj.LeadField),
    obj = make_source_dipoles_leadfield(obj); 
end

end

