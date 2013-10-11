function ok(bool, testName, reason)
% OK - Tests whether a test was passed or not
%
% ok(bool, testName)
%
% Where
%
% BOOL is a boolean value. If BOOL is true the test passed, if it is
% false then it didn't. This function prints out either "ok" or "not ok"
% along with a test number (it keeps track of that for you). Alternatively,
% BOOL can be an MException object.
%
% If you provide a testName, that will be printed along the "ok/not ok"to make
% it easier to find your test when it fails (just search for the testName). It
% also makes it easier for the next guy to understand what your test is
% for. It's highly recommended you use test names.
%
% ## Notes:
%
% * This function aims to be an equivalent to function ok from Perl's core
%   module Test::Simple. This documentation has been partially copied and
%   pasted from Test::Simple's online documentation:
%   http://perldoc.perl.org/Test/Simple.html
%
%
% See also: test.simple

% Description: Tests whether a test was passed
% Documentation: pkg_simple.txt

import test.simple.globals;
import misc.str2multiline;
import misc.link2mfile;
import misc.quote;
import test.simple.st2debug;

try
    if nargin < 3 || isempty(reason),
        reason = '';
    end
    if nargin < 2 || isempty(testName),
        testName = '';
    end
    
    okCount     = globals.get.OK;
    failedCount = globals.get.Failed;
    
    count = okCount + failedCount;
    
    if islogical(bool) && all(bool),
        
        globals.set('OK', okCount + 1);
        if isempty(testName),
            fprintf('ok %d\n', count + 1);
        else
            fprintf('ok %d - %s\n', count + 1, testName);
        end
        
    else        
        
        errorMsg = '';        
        
        if isa(bool, 'MException'),
            
            if globals.get.DebugMode,
                rethrow(bool);
            else
                [name, file, line] = st2debug(bool.stack);
                errorMsg = bool.message;
            end
            
        elseif islogical(bool) || isnan(bool),            
            [name, file, line] = st2debug(dbstack('-completenames'));         
        else            
            error('A boolean value or a MException object was expected');            
        end
        
        if ~isa(bool, 'MException') && isnan(bool),
            % skipped test
            msg = 'skipped ';
            globals.set('OK', okCount + 1);
        else
            msg = 'not ok ';
            globals.set('Failed', failedCount + 1);
            if globals.get.DebugMode,
                throw(MException('test:simple:ok:FailedTest', ...
                    'Failed test in debug mode'));
            end
        end
        
        [~, fName, fExt] = fileparts(file);
        
        if isempty(testName),
            fprintf('%s %d\n', msg, count + 1);
        else
            fprintf('%s %d - %s\n', msg, count + 1, testName);
            if ~isa(bool, 'MException') && isnan(bool),
                fprintf('#\tSkipped test ''%s''\n', testName);
            else
                fprintf('#\tFailed test ''%s''\n', testName);
            end
        end
        
        if ~isempty(reason),            
            fprintf('#\tFor reason ''%s''\n', reason);            
        end
        
        if ~isempty(testName),            
            fprintf('#\tin ''%s''\n', name);            
        end        
        
        if ~isempty(file)            
            fprintf(['#\tin file ' ...
                quote(link2mfile(which(file), [fName fExt])), ...
                ' at ' ...
                quote(link2mfile(which(file), ...
                sprintf('line %d', line), line)) ...
                '\n']);            
        end
        
        if ~isempty(errorMsg),
            errorMsg = str2multiline(errorMsg, [], ['# ' char(9)]);
            fprintf('#\tWith error message:\n%s\n', quote(errorMsg));
        end
        
    end
    
catch ME
    
    if globals.get.DebugMode,
        rethrow(ME);
    end
    
    globals.set('Died', globals.get.Died + 1);
    if isempty(testName),
        fprintf('died %d\n', count + 1);
    else
        fprintf('died %d - %s\n', count + 1, testName);
    end
    fprintf('#\t%s\n', ME.message);
    
    st   = ME.stack;
    file = st(1).file;
    line = st(1).line;
    
    [~, fName, fExt] = fileparts(file);
    
    fprintf(['#\tin file ' ...
        quote(link2mfile(which(file), [fName fExt])), ...
        ' at ' ...
        quote(link2mfile(which(file), sprintf('line %d', line), line)) ...
        '\n']);
    
    
end

end
