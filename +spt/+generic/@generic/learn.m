function obj = learn(obj, data, ev, sr)
% LEARN - Learns spatial basis functions
%
%
% obj = learn(obj, data, ev)
%
%
% Where
%
% OBJ is a spt.generic.generic object
%
% DATA is the data to be used for learning. It must a numeric data matrix
% with data samples columnwise and data channels rowwise. It can also be a
% pset.physioset object or pset.pset object.
%
%
% See also: spt.generic.generic, spt


import misc.join;
import misc.signal2hankel;
import goo.pkgisa;
import misc.dimtype_str;
import goo.globals;

if nargin < 4, sr = []; end
if nargin < 3, ev = []; end

% Configuration options
filtObj  = get_config(obj, 'Filter');
embedDim = get_config(obj, 'EmbedDim');
dataSel  = get_config(obj, 'DataSelector');

% Status messages
verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

origVerbose = globals.get.Verbose;
globals.set('Verbose', false);

origVerboseLabel = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

%if size(data,2) < size(data,1), data = transpose(data); end

isPhysioset = pkgisa(data, 'physioset.physioset');

if isPhysioset && isa(filtObj, 'function_handle'),
    filtObj = filtObj(data.SamplingRate);
end

if ~isempty(filtObj),
    
    if isPhysioset,
        data = copy(data);
    end

    if isa(filtObj, 'function_handle'),
        if isPhysioset,
            if ~isempty(sr) && data.SamplingRate ~= sr,
                warning('learn:InconsistentSamplingRate', ...
                    ['Input data rate does not match explicitely ' ...
                    'provided sampling rate']);
            end
            filtObj = filtObj(data.SamplingRate);    
        elseif ~isempty(sr),
            filtObj = filtObj(sr);
        else
            error('Unknown data sampling rate: cannot build filter object');
        end
    end
    
    data = filter(filtObj, data);
    
end

if isPhysioset && ~isempty(dataSel),
    select(dataSel, data);
end

if verbose,
    
    fprintf([verboseLabel ...
        'Learning from %s data\n\n'], dimtype_str(data));
    
    fprintf(...
        [verboseLabel 'Learning %d spatial basis functions with %s...'], ...
        embedDim*size(data,1), class(obj));
end

if embedDim > 1,
    
    X = signal2hankel(data(:,:), embedDim);
    
else
    
    X = data(:,:);
    
end

if isPhysioset && ~isempty(ev),
    ev = get_event(data);
end

if size(data,1) == 1,
    
    warning('abstract_spt:learn:OneDimensionalData', ...
        'Cannot learn spatial basis from one dimensional data!');
    W           = 1;
    A           = 1;
    selection   = 1;
    
elseif size(X, 1) > 1,
    
    [W, A, selection, obj] = learn_basis(obj, X, ev);
    
else
    
    error('No data was provided!');
    
end

obj = set_basis(obj, W, A);
obj = deselect(obj, 'all');
obj = select(obj, selection);

if verbose,
    
    fprintf('[selected %d basis]\n\n', numel(selection));
    
end

if isPhysioset && ~isempty(dataSel),
    restore_selection(data);
end

globals.set('VerboseLabel', origVerboseLabel);
globals.set('Verbose', origVerbose);