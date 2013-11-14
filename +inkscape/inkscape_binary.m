function str = inkscape_binary()
% INKSCAPE_BINARY - Full path to Inkscape's binary

import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;
import mperl.file.spec.rel2abs;
import mperl.cwd.abs_path;
import inkscape.root_path;
import inkscape.dir;

str = 'inkscape';

% user ini file takes preference over all
userIni  = catfile(root_path, '..', '..', 'meegpipe.ini');
meegIni  = catfile(root_path, '..', '..', 'meegpipe', '+meegpipe','meegpipe.ini');
thisIni = catfile(root_path, 'inkscape.ini');

ini = [];
if exist(userIni, 'file'),
    tmpIni = inifile(userIni);
    if section_exists(tmpIni, 'inkscape'),
        ini = tmpIni;
    end
end

if isempty(ini) && exist(meegIni, 'file'),
    tmpIni = inifile(meegIni);
    if section_exists(tmpIni, 'inkscape'),
        ini = tmpIni;
    end
end

if isempty(ini) && exist(thisIni, 'file')
    tmpIni = inifile(meegIni);
    if section_exists(tmpIni, 'inkscape'),
        ini = tmpIni;
    end
end

if isempty(ini),
    ini = inifile(catfile(root_path, 'inkscape.ini'));
end


path = val(ini, 'inkscape', 'path', true);

for i = 1:numel(path)
    
    thisPath = abs_path(rel2abs(path{i}, root_path));
    if exist(thisPath, 'dir'),
        
        if ispc,
            regex = 'inkscape\.exe$';
        else
            regex = 'inkscape$';
        end
        fileList = dir(thisPath, regex);
        
        if numel(fileList) > 1,
            error('Multiple matches for inkscape binary');
        elseif ~isempty(fileList),
            str = catfile(thisPath, fileList{1});
            return;
        end
        
    end
    
end

end