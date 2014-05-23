function pObj = import(obj, varargin)
% IMPORT - Imports files in NBT format
%
% pObj = import(obj, fileName)
% pObjArray = import(obj, fileName1, fileName2, ...);
%
% ## Notes:
%
%   
%
% See also: mff

import physioset.physioset;
import pset.file_naming_policy;
import pset.globals;

misc.check_dependency('eeglab');

if numel(varargin) == 1 && iscell(varargin{1}),
    varargin = varargin{1};
end

% Deal with the multi-newFileName case
if numel(varargin) > 2
    pObj = cell(numel(varargin), 1);
    for i = 1:numel(varargin)
        pObj{i} = import(obj, varargin{i});
    end
    return;
end

fileName = varargin{1};

[fileName, obj] = resolve_link(obj, fileName);

% Default values of optional input arguments
verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);
origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

% Determine the names of the generated (imported) files
if isempty(obj.FileName),   
    newFileName = file_naming_policy(obj.FileNaming, fileName);
    dataFileExt = globals.get.DataFileExt;
    newFileName = [newFileName dataFileExt];  
else  
    newFileName = obj.FileName;
end


cmd = sprintf('EEG = nbt_NBTsignal2EEGlab(''%s'');',fileName);
evalc(cmd);
pObj = physioset.from_nbt(EEG, EEG.NBTinfo, ...
    'FileName', newFileName, 'SensorClass', obj.SensorClass);


%% Undoing stuff 

% Unset the global verbose
goo.globals.set('VerboseLabel', origVerboseLabel);

end