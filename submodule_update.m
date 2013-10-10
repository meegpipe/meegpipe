function submodule_update(username, add2path, testing)
% SUBMODULE_UPDATE - Updates MATLAB submodules
%
% ## Usage synopsis:
%
% cd path/to/repo
% submodule_update
% submodule_update(user)
% submodule_update(user, add2path);
% submodule_update(user, add2path, testing);
%
% Where
%
% USER is the github username that will be used to connect to GitHub when
% cloning the remote repositories. If not provided, GitHub will be accessed
% anonimously using the git:// protocol.
%
% If ADD2PATH is true then PKGPATH (and all its dependencies) will be
% automatically added to MATLAB's search path. Default: false
%
% TESTING is a boolean flag, indicating whether to update the standard
% dependencies (TESTING=false) or the dependencies that are needed only for
% testing purposes (TESTING=true)
%
% See also: submodule_add

% Wait this number of seconds after each cloning operation. GitHub does not
% always like when too many clone requests come too fast.
WAIT = 1;

if nargin < 3 || isempty(testing), testing = false; end
if nargin < 2 || isempty(add2path), add2path = false; end
if nargin < 1 || isempty(username), username = ''; end

persistent alreadyUpdated;

pkgPath = get_repo_pkg(pwd);

baseDir    = fullfile(pkgPath, '..');
baseDir    = abs_path(baseDir);
subModsDir = abs_path(fullfile(baseDir, '..'));


dirName    = [pkgPath filesep '.matlab_submodules'];

if testing,
    dirName = [dirName '_testing'];
end

modList    = dir(dirName);

if ~isempty(alreadyUpdated) && ismember(pkgPath, alreadyUpdated),
    return;
end

% Add current module to MATLAB's path (use absolute path)
if add2path,
    addpath(abs_path(fullfile(pkgPath, '..')));
end

% Do a pull and a submodule update
[~, res] = system('git pull');
if ~isempty(res) && ~isempty(regexp(res, '^error.+https.+disabled', 'once')),
    % Problem related with MATLAB using its own libcurl
    % Try to fix making a symbolic link to the proper libcurl
    fix_libcurl();
else
    [~, name] = fileparts(pwd);
    name = ['-> ' name];
    if numel(res) < (60-numel(name)-7),
        tmp = repmat('.', 1, 60);
        tmp(end-numel(res):end) = [' ' res];
        tmp(1:numel(name)+1) = [name ' '];
        fprintf(tmp);
    else
        fprintf([name ' :\n']);
        disp(res);
    end
end

system('git submodule update --init --recursive');

alreadyUpdated = [alreadyUpdated;{pkgPath}];

for i = 1:numel(modList)
    
    modName = modList(i).name;
    
    if strcmp(modName, '.') || strcmp(modName, '..'),
        continue;
    end
    
    if ~exist(subModsDir, 'dir')
        mkdir(subModsDir);
    end
    
    cloneDir = fullfile(subModsDir, modName);
    
    try
        
        if ~exist(cloneDir, 'dir') || numel(dir(subModsDir))<3,
            % Clone the repo
            fid = fopen(fullfile(dirName, modName, 'url'), 'r');
            url = fgetl(fid);
            fclose(fid);
            
            % Take of existing username specifications in the URL
            url = regexprep(url, '([^/@]+)@', '');
            
            % Set the url to the correct user
            if isempty(username),
                % Use git:// to access github anonimously
                url = regexprep(url, '^(\w+://)', 'git://');
            else
                url = regexprep(url, '^(\w+://)(.+)', ['http://' username '@$2']);
            end
            
            cmd1 = sprintf('git clone %s %s', url, modName);
            currDir = pwd;
            cd(subModsDir);
            system(cmd1);
            pause(WAIT)
            cd(currDir);
        end
        
        % Call recursively for the submodule that we just cloned
        depDir  = fullfile(subModsDir, modName);
        currDir = pwd;
        cd(depDir);
        submodule_update(username, add2path, testing);
        cd(currDir);
        
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

if numel(dbstack)< 2,
    % calling from main workspace
    clear alreadyUpdated;
end


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


function fix_libcurl()
import meegpipe.regexpi_dir;

msg = [...
    'Your MATLAB needs a small fix for submodule_update to work:\n', ...
    '1) File %s needs to be renamed to %s\n', ...
    '2) Symbolic link %s -> %s needs to be created\n', ...
    '\n', ...
    'This operation is safe and you can always restore your original\n', ...
    'original MATLAB configuration by undoing the steps above. You may\n' ...
    'need to provide an administrative account password to perform this\n' ...
    'operation.\n\n', ...
    'Proceed? [y/n] ' ...
    ];

if ismac,
    % Location of the offending library
    libBad = ...
        [matlabroot filesep 'bin' filesep lower(computer) filesep ...
        'libcurl.4.dylib'];
    
    % Location of the proper library
    [~, curlBin] = system('which curl');
    
    
    [~, res] = system(['otool -L ' curlBin]);
    libProper = regexprep(res, '.+\s(.+libcurl.4.dylib)\s.+', '$1');
    
    errorMsg = sprintf(msg, libBad, [libBad '.backup'], libBad, ...
        libProper);
    val = input(errorMsg, 's');
    
    if strcmpi(val, 'y'),
        % Rename offending library
        system(sprintf('sudo mv %s %s', libBad, [libBad '.backup']));
        
        % Create symbolic link to the proper library
        system(sprintf('sudo ln -s %s %s', libProper, libBad));
    else
        error('Ask g@germangh.com how to fix this problem: libcurl');
    end
    
else
    error('Ask g@germangh.com how to fix this problem: libcurl');
end



end

