function [data, dataNew] = process(obj, data, varargin)

import mperl.file.spec.catfile;

dataNew = [];

fileName = get_config(obj, 'Filename');

if isempty(fileName)
    if obj.Save,
        % Default filename should be stored in the node directory
        fileName = catfile(get_full_dir(obj, data), get_name(data));
    else
        [~, name] = fileparts(tempname);
        fileName = catfile(get_tempdir(obj), name);
    end
end

data = copy(data,    ...  
    'Path',         get_config(obj, 'Path'), ...
    'PostFix',      get_config(obj, 'PostFix'), ...
    'PreFix',       get_config(obj, 'PreFix'), ...
    'DataFile',     fileName, ...
    'Temporary',    ~obj.Save);

end