function [status, MEh] = test2()
% TEST2 - Static constructors

import meegpipe.node.bss_regr.*;
import test.simple.*;

MEh     = [];

initialize(5);



%% bcg
try

    name = 'bcg';
    bcg;
    ok(true, name);

catch ME

    ok(ME, name);
    MEh = [MEh ME];

end

%% ecg
try

    name = 'ecg';
    ecg;
    ok(true, name);

catch ME

    ok(ME, name);
    MEh = [MEh ME];

end

%% emg
try

    name = 'emg';
    emg;
    ok(true, name);

catch ME

    ok(ME, name);
    MEh = [MEh ME];

end

%% eog
try

    name = 'eog';
    eog;
    ok(true, name);

catch ME

    ok(ME, name);
    MEh = [MEh ME];

end


% pwl
try

    name = 'pwl';
    pwl;
    ok(true, name);

catch ME

    ok(ME, name);
    MEh = [MEh ME];

end



%% Testing summary
status = finalize();