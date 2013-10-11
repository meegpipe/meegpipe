function remark(folder)
% REMARK - Generate HTML report using Remark [1]
%
% remark(folder)
%
% Where
%
% FOLDER is the directory where the Remark sources are located
%
% ## References:
%
%   [1] http://kaba.hilvi.org/remark/remark.htm
%
%
% See also: report


import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;
import goo.globals;
import meegpipe.root_path;

verbose         = globals.get.Verbose;
verboseLabel    = globals.get.VerboseLabel;

if nargin < 1 || isempty(folder), folder = pwd; end

cmd0 = catfile(root_path, '../../external_remark/remark/Remark/remark.py');

if isunix,
    quotes = '''';
else
    quotes = '"';
end

if isunix,
    cmd = ['source ~/.bashrc ; python ' cmd0];
    [~, msg1] = system(cmd);
    if isempty(regexpi(msg1, 'Usage:\s+remark.py')),
        % The .bashrc may be missing ...
        cmd = ['python ' cmd0];
        [~, msg] = system(cmd);
    else
        msg = msg1;
    end
        
else
    cmd = ['python ' quotes cmd0 quotes];
    [~, msg] = system(cmd);
end

if verbose,
   fprintf([verboseLabel 'Executed: ''%s'' ...\n\n'], cmd);
   if isempty(regexpi(msg, 'Usage:\s+remark.py')),
      fprintf([verboseLabel 'Unexpected response from OS: \n\n%s'], ...
          msg);
      fprintf('\n\n');
   end
end

% Is Remark installed somewhere else or has some other name?
if isempty(regexpi(msg, 'Usage:\s+remark.py')),
    [~, msg] = system('remark');
    if isempty(regexpi(msg, '^\s+Usage\s')),
        [~, msg] = system('remark.py');
        if isempty(regexpi(msg, '^\W*Usage')) && isunix,
            % Try running bashrc first
            cmd = 'source ~/.bashrc; remark';
            [~, msg] = system(cmd);
            if isunix && isempty(regexpi(msg, '^\W*Usage')),
                cmd = 'source ~/.bashrc; remark.py';
                [~, msg] = system(cmd);
                if isempty(regexpi(msg, 'Usage:\s+remark.py')),
                    error('Remark is not installed in this system');
                else
                    cmd = 'source ~/.bashrc; remark.py';
                end
            else
                cmd = 'source ~/.bashrc; remark';
            end
        else
            cmd = 'remark.py';
        end
    else
        cmd = 'remark';
    end
end

if verbose,
    fprintf([verboseLabel ...
        'Compiling Remark report ...']);
end

cmd = sprintf('%s %s%s%s %s%s%s %s*.png%s %s*.svg%s %s*.txt%s', cmd, ...
    quotes, folder, quotes, quotes, folder, quotes, ...
    quotes,quotes,quotes,quotes,quotes,quotes);

[status, res] = system(cmd);

if status && verbose
    fprintf('[failed, see below]\n\n');
elseif verbose
    fprintf('\n\n');
end

if verbose    
    res = strrep(res, char(10), [char(10) char(9) 'system->    ']);
    res = [char(9) 'system->    ' res '\n\n'];
    disp(res);    
    fprintf([verboseLabel 'End of Remark output\n\n']);
end

source = catfile(report.root_path, 'remark.css');
target = catfile(folder, 'remark_files', 'remark.css');
[success, msg] = copyfile(source, target);
if ~success,
   warning('remark:UnableToCopyCSS', ...
       'Not able to copy custom CSS settings: %s', msg);
end

end