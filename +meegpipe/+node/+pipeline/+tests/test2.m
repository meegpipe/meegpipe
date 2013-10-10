function [status, MEh] = test2()
% TEST2 - Template-based pipelines

import test.simple.*;

MEh     = [];

templates = {...
    'basic', ...
    'bcg_cwr_filt', ...
    'bcg_cwr_mcombi_lasip', ...
    'bcg_mcombi', ...
    'bcg_mcombi_lasip', ...
    'bcg_obs', ...
    'bcg_obs_ica' ...
    };    

initialize(numel(templates));


%% default constructors
for i = 1:numel(templates)
    try
        
        name = templates{i};
        feval(['meegpipe.node.pipeline.' templates{i}], 250);
        ok(true, name);
        
    catch ME
        
        ok(ME, name);
        MEh = [MEh ME]; %#ok<AGROW>
        
    end
end


%% Testing summary
status = finalize();