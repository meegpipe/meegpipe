function obj = set_runtime(obj, section, param, varargin)

import mperl.file.spec.catfile;

cfg = get_runtime_config(obj);

% Create a backup of the previous configuration
[path, name, ext] = fileparts(cfg.File);
backupFile = catfile(path, [name '_' datestr(now, 'yymmddHHMMSS') ext]);
copyfile(cfg.File, backupFile);

if ~section_exists(cfg, section),
    add_section(cfg, section);
end

if exists(cfg, section, param),
    setval(cfg, section, param, varargin{:}); 
else
    newval(cfg, section, param, varargin{:});
end
    

end