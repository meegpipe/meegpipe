function [modRev, modList] = submodule_revision(dirName)
% SUBMODULE_REVISION - Revision number for submodules
%
% ## Usage synopsis:
%
% [modRev, modList] = submodule_revision()
%
%
% Where
%
% MODLIST is a list of submodules (a cell array of strings).
%
% MODREV is a list of corresponding revision numbers (a cell array of
% strings)
%
% See also: submodule_list, submodule_update, submodule_add


if nargin < 1 || isempty(dirName),
    dirName = pwd;
end

clear submodule_list;
[modList, modDir] = submodule_list(dirName);

% Include also the current repo in the list of submodules
[~, pkgName] = get_repo_pkg(dirName);
modList = [{pkgName}; modList];
modDir  = [{dirName}; modDir];

currDir = pwd;
modRev = cell(size(modDir));

try
    for i = 1:numel(modDir)
        
        cd(modDir{i});
        [~, res] = system('git rev-list HEAD');
        res = split(char(10), res);
        modRev{i} = res{1};
        
    end
    
catch ME
    cd(currDir);
    rethrow(ME);
end

% Sort in alphabetical order
[modList, idx] = sort(modList);
modRev = modRev(idx);

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

function y = split(sep, str, noSep)
% SPLIT - Splits a string into a cell array of strings
%
% y = split(sep, str, noSep)
%
% Where
%
% STR is a char array.
%
% SEP is the separator character based on which the input string should be
% splitted.
%
% Y is a cell array that contains the portions of STR that are separated by
% separator SEP.
%
% NOSEP is a logical scalar. If set to true and the separator is not found
% in STR, then split() will return the input string, i.e. Y=STR. On the
% other hand, if NOSEP=false and the separator was not found with STR then
% split() will return an empty value.
%
% See also: join


if nargin < 3 || isempty(noSep),
    noSep = false;
end

idx = strfind(str, sep);

if isempty(idx),
    if noSep,
        y = str;
    else
        y = [];
    end
    
    return;
end

nSep = numel(sep);

y = cell(numel(idx)+1,1);
first = 1;
for i = 1:numel(idx)
   last = idx(i)-1;
   y{i} = str(first:last);
   first = last+1+nSep;
end
y{i+1} = str(first:end);
if isempty(y{end}), y = y(1:end-1); end


end