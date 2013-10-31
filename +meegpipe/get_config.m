function value = get_config(varargin)
% GET_CONFIG - Get user configuration options for EEGPIPE

import mperl.config.inifiles.inifile;
import meegpipe.root_path;
import mperl.file.spec.catfile;

sysIni  = catfile(root_path, 'meegpipe.ini');
userIni = catfile(root_path, '..', '..', 'meegpipe.ini');

if ~exist(userIni, 'file'), 
    userIni = catfile(root_path, '..', '..', '..', 'meegpipe.ini');
end

if ~exist(userIni, 'file'),
    userIni = catfile(pwd, 'meegpipe.ini');
end

if exist(userIni, 'file'),
    cfg = inifile(userIni);
elseif exist(sysIni, 'file')    
    cfg = inifile(sysIni);
else
    error('No configuration file!');
end

if nargin < 1,
    value = cfg;
    return;
end

cfg = val(cfg, varargin{:});

try
    value = eval(cfg);
catch ME
    catchedErrors = {'MATLAB:m_missing_variable_or_function', ...
        'MATLAB:UndefinedFunction'};
    if ismember(ME.identifier, catchedErrors)
        value = cfg;
    else
        rethrow(ME);
    end
end


end