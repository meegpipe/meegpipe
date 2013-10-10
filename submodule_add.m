function submodule_add(name, url, pkgPath, testing)
% submodule_add(depName, url);
% submodule_add('io', 'http://github.com/germangh/matlab_io');
% submodule_add('io');
%
% Where 
%
% DEPNAME is a unique name identifying the dependency sub-module.
%
% URL is the location of the dependency GIT repository.
%
%
% ## Important note:
%
% No username needs to be provided in the URL. The relevant username is
% specified when calling to submodule_update
% 
%
% See also: submodule_update

if nargin < 4 || isempty(testing),
    testing = false;
end

if nargin < 3 || isempty(pkgPath),
    
    pkgPath = get_repo_pkg(pwd);
    
end

pkgPath = abs_path(pkgPath);

if isempty(name),
    error('A dependency name needs to be provided');
end

if nargin < 2 || isempty(url),
    url = [default_base_url name];
end

dirName  = [pkgPath filesep '.matlab_submodules'];

if testing,
    dirName = [dirName '_testing'];
end

modDirName  = [dirName filesep name];
fName       = [modDirName filesep 'url'];

if exist(fName, 'file'),
    warning('add_submodule:ExistingSubmodule', ...
        'Submodule %s already exists', name);
    return;
end

if ~exist(dirName, 'dir'),
    mkdir(dirName);
end

if ~exist(modDirName, 'dir'),
    mkdir(modDirName);
end

try   
    fid = fopen(fName, 'w');    
    
    fprintf(fid, '%s', url);    
    
    fclose(fid);
    
catch ME
    
    if exist('fid', 'var') && fid > 0, 
        try
            fclose(fid);
        catch ME2
            if ~strcmpi(ME.identifier, 'MATLAB:badfid_mx'),
                rethrow(ME2);
            end
        end                
    end
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


function y = abs_path(pathName)

currDir = pwd;
cd(pathName);
y = pwd;
cd(currDir);

end
