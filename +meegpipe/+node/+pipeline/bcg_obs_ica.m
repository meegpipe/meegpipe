function obj = bcg_obs_ica(sr, varargin)
% BCG_OBS_ICA - Pipeline that emulates the OBS-ICA BCG correction approach [1]
%
% ## Usage synopsis:
%
% import meegpipe.node.pipeline.bcg_obs_ica;
% myPipe = bcg_obs_ica(sr, 'key', value, ...);
% data   = run(myPipe, 'myfile.mff');
%
% where
%
% SR is the data sampling rate at the input of the pipeline.
%
% ## Accepted key value pairs:
%
%   * All keys accepted by the constructor of class pipeline
%
% ## References
%
% [1] Debener et al, 2007, Neuroimage 34, 587-597.
%
% See also: meegpipe.node.pipeline

import meegpipe.*;
eval(alias_import('nodes'));
import spt.bss.jade.jade;
import spt.criterion.topo_template.topo_template;
import misc.isnatural;

if nargin < 1 || isempty(sr) || ~isnatural(sr),
    error('The data sampling rate must be provided');
end

icaCrit = topo_template.bcg(...
    'MinCard',      1, ...
    'MaxCard',      1 ...
    );

icaNode =  bss_regr.bcg(sr/4, ...
    'BSS',          jade, ...
    'RegrFilter',   filter.mlag_regr('Order', 0), ...
    'Criterion',    icaCrit ...  
    );

obj  = pipeline('NodeList', ...
    { ...
    pipeline.basic(sr), ...
    qrs_detect, ...
    obs, ...
    icaNode ...
    }, ...
    'Name', 'obs_ica', ...
    'Save', true, ...
    ...
    varargin{:});




end