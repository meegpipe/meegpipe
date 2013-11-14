function status = make_test(varargin)
% MAKE_TEST - Tests a package
%
% See also: test.simple

import misc.dir;
import mperl.file.spec.*;
import test.simple.globals;
import misc.link2mfile;

if nargin < 1,
    status = test.simple.globals.get.Failure;
    warning('make_test:NoTests', 'Did not run any test');
    return;
end


verboseLabel = '(make_test) ';
status = false(1, nargin);

for j = 1:nargin
    module = varargin{j};
    
    path = feval([module '.root_path']);
    
    files = dir(catdir(path, '+tests'), '\.m$');
    
    thisStatus  = repmat(globals.get.Failure, 1, numel(files));
    
    for i = 1:numel(files)
        
        [~, name] = fileparts(files{i});
        
        funcName = [module '.tests.' name];
        fprintf([verboseLabel link2mfile(funcName) '\n']);
        
        cmd = sprintf('%s.tests.%s', module, name);
     
        thisStatus(i) = feval(cmd);
        
        fprintf('\n\n');
        
    end
    
    status(j) = any(thisStatus ~= globals.get.Success);
    
end

end