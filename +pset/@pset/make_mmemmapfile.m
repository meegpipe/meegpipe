function obj = make_mmemmapfile(obj)
% DESTROY_MMEMMAPFILE Re-makes the memory map(s) associated with a pset
% object
%
% obj = make_mmemmapfile(obj)
%
%
% (c) German Gomez-Herrero
% Contact: german.gomezherrero@ieee.org
%
% See also: pset.

import pset.pset;
import pset.globals;

mapsize = globals.get.MapSize;

% Number of points stored in the file
fid = fopen(obj.DataFile);
if fid < 0,
    ME = MException('pset:make_mmemmapfile:InvalidFile', ...
        'I could not open file: %s', obj.DataFile);
    throw(ME);
end
   
n_points = pset.get_nb_points(fid, obj.NbDims, obj.Precision);
fclose(fid);

[obj.MemoryMap, obj.MapIndices] = pset.mmemmapfile(obj.DataFile, obj.NbDims, ...
    n_points, obj.Precision, 'MapSize', mapsize,...
    'Writable', obj.Writable);

obj.NbPoints = n_points;
