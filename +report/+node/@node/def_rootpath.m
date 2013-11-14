function [repFolder, repFileFolder] = def_rootpath(obj, varargin)

import mperl.file.spec.catdir;


repFolder = catdir(get_save_dir(obj.Node_), 'remark');
repFileFolder = strrep(repFolder, 'remark', 'remark_files');



end