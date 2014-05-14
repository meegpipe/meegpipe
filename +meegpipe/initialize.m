function initialize(cfg)

import mperl.config.inifiles.inifile;
import mperl.file.spec.*;
import mperl.cwd.abs_path;
import meegpipe.get_config;
import misc.existing_dir;
import mperl.join;
import mperl.split;
import meegpipe.root_path;
import mjava.hash;

% Root dirs of all dependencies
depRoot = hash;

verboseLabel = '(meegpipe) ';

fprintf(['\n\n' verboseLabel 'Initializing...\n\n']);

if nargin < 1 || isempty(cfg),
    cfg = get_config();
    fprintf([verboseLabel 'Read meegpipe configuration from %s\n\n'], ...
        cfg.File);
end

%% Add dependencies to the path
depList = group_members(cfg, 'matlab');

if isempty(depList),
    warning('meegpipe:initialize:MissingDependencyList', ...
        ['No matlab-dependencies section found in %s\n' ...
        'The configuration file may be invalid'], cfg.File);
end

if ischar(depList) && ~isempty(depList), depList = {depList}; end

for i = 1:numel(depList)
    
    uniqueFile = val(cfg, depList{i}, 'unique_mfile');
    fullPathToFile = which(uniqueFile);
    if isempty(fullPathToFile),
        warning('meegpipe:initialize:MissingDependency', ...
            'Could not find dependency: %s', depList{i});
    else
        depPath = fileparts(fullPathToFile);
        depPath = strrep(rel2abs(depPath), '\', '/');
        depRoot(depList{i}) = depPath;
        fprintf([verboseLabel 'Found %s: %s\n\n'], upper(depList{i}), depPath);
        addpath(genpath(depPath));
        % Remove problematic paths
        probPaths = val(cfg, depList{i}, 'problematic_paths', true);
        probPaths = cellfun(@(x, y) [depRoot(x) y], ...
            repmat(depList(i), numel(probPaths), 1), probPaths, ...
            'UniformOutput', false);
        remove_from_path(probPaths);
    end
    
end

fprintf([verboseLabel 'Done with initialization\n\n']);


end


function remove_from_path(dirList)

import mperl.join;
import mperl.split;
import misc.dir;

verboseLabel = '(meegpipe) ';

if isunix, sep = ':'; else sep = ';'; end
pathList = split(sep, path);
pathList2 = cellfun(@(x) strrep(x, '\', '/'), pathList, ...
    'UniformOutput', false);

% Remove also sub-directories
subdirList = cell(size(dirList));
for i = 1:numel(subdirList)
    if ~exist(dirList{i}, 'dir'), continue; end
    thisSubdirs = dir(dirList{i}, '.+', true, true);
    if ~isempty(thisSubdirs),
        subdirList(i) = thisSubdirs;
    end
end
dirList = [dirList(:); cell2mat(subdirList)];

fprintf([verboseLabel 'Attempting to remove problematic dirs from path:\n\n']);
fprintf(join('\n', dirList));
fprintf('\n\n');

fprintf([verboseLabel 'Removed the following paths:\n\n']);
fprintf(join('\n', dirList));
for i = 1:numel(dirList)
    
    isProblematic = cellfun(@(x) ~isempty(strfind(x, dirList{i})), pathList2);
    if ~any(isProblematic), continue; end
    tobeRemoved = pathList(isProblematic);
    tobeRemoved = cellfun(@(x) strrep(x, '\', '/'), tobeRemoved, 'UniformOutput', false);
    fprintf(join('\n', tobeRemoved));
    cellfun(@(x) rmpath(x), tobeRemoved);
    
end
fprintf('\n\n');

end