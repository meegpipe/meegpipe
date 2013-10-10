function obj = bcg_obs(sr, varargin)
% BCG_OBS - Removal of BCG artifacts using optimal basis sets [1]
%
% ## Usage synopsis:
%
% import meegpipe.node.pipeline.bcg_obs;
% myPipe = bcg_obs(sr, 'key', value, ...);
% data   = run(myPipe, 'myfile.mff');
%
% Where
%
% SR is the sampling rate at the input of the pipeline.
%
%
% ## Accepted key value pairs:
%
%   * All keys accepted by the constructor of class pipeline
%
%
% ## References
%
% [1] Niazy et al., 2005, Removal of FMRI environment artifacts from EEG
%     data using optimal basis sets, NeuroImage.
%
% See also: meegpipe.node.pipeline

import meegpipe.*;
eval(alias_import('nodes'));
import meegpipe.node.pipeline.basic;

obj  = pipeline('NodeList', ...
    { ...
    basic(sr), ...
    qrs_detect, ...
    obs, ...
    }, ...
    'Name', 'obs', ...
    'Save', true, ...
    ...
    varargin{:});


end