function submodule_checkout(varargin)
% SUBMODULE_CHECKOUT - Checks out a specific revision of each submodule
%
%
%
% See also: submodule_list, submodule_update, submodule_add

if nargin == 1,
    file = varargin{1};
    fid = fopen(file, 'r');
    try
        evalc(fgetl(fid));
        evalc(fgetl(fid));
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    fclose(fid);
elseif nargin == 2
    modList = varargin{1};
    modRev = varargin{2};
else
    error('Wrong number of input arguments');
end

% List of submodules
clear submodule_list;
[currModList, currModDir] = submodule_list();

currDir = pwd;

[~, pkgName] = get_repo_pkg(currDir);
[isMember, locB] = ismember(pkgName, modList);
if isMember,
    [~,~] = system(['git checkout ' modRev{locB}]);
end

try
    for i = 1:numel(modList),
        
        [isMember, locB] = ismember(modList{i}, currModList);
        if isMember,
            cd(currModDir{locB});
            [~,~] = system(['git checkout ' modRev{i}]);
            cd(currDir);
        end
        
    end
catch ME
    cd(currDir);
    rethrow(ME);
end


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