function [modList, dirList] = submodule_list(dirName)
% SUBMODULE_LIST - List submodule dependencies
%
% ## Usage synopsis:
%
% cd path/to/repo
% [modList, dirList] = submodule_list()
% 
% Where
%
% MODLIST is a list of submodules (a cell array of strings).
%
% DIRLIST is a list of corresponding submodule directories (a cell array of
% strings).
%
% See also: submodule_update, submodule_add

if nargin < 1 || isempty(dirName),
    dirName = pwd;
end

persistent alreadyUpdated;

pkgPath = get_repo_pkg(dirName);

baseDir    = fullfile(pkgPath, '..');
baseDir    = abs_path(baseDir);
subModsDir = abs_path(fullfile(baseDir, '..'));

dirName     = [pkgPath filesep '.matlab_submodules'];

modListOrig = dir(dirName);

if ~isempty(alreadyUpdated) && ismember(pkgPath, alreadyUpdated),
    modList = {};
    dirList = {};
    return;
end

modListAll = {};
dirListAll = {};

alreadyUpdated = [alreadyUpdated;{pkgPath}];

for i = 1:numel(modListOrig)
   
    modName = modListOrig(i).name;  
    
    if strcmp(modName, '.') || strcmp(modName, '..'),
        continue;
    end
    
    cloneDir = fullfile(subModsDir, modName);
    
    [modList, dirList] = submodule_list(cloneDir);
    
    modListAll = [modListAll(:);{modName};modList(:)];
    dirListAll = [dirListAll(:);{cloneDir};dirList(:)];
    
end

modList = unique(modListAll);
dirList = unique(dirListAll);


end


function y = abs_path(pathName)

currDir = pwd;
cd(pathName);
y = pwd;
cd(currDir);

end


function [pkgPath, pkgName] = get_repo_pkg(repoPath)

names = dir(repoPath);
for i = 1:numel(names),
    if strcmp(names(i).name(1), '+'),
        pkgName = names(i).name(2:end);
        pkgPath = fullfile(repoPath, names(i).name);        
        return;
    end
end

pkgPath = '';
pkgName = '';

end