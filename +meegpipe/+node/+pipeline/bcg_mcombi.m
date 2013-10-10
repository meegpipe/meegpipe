function obj = bcg_mcombi(sr, varargin)
% BCG_MCOMBI - Pipeline for BCG correction using multicombi
%
% ## Usage synopsis:
%
% import meegpipe.node.pipeline.bcg_mcombi;
% myPipe = bcg_mcombi(sr, 'key', value, ...);
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
% See also: pipeline

import meegpipe.*;
eval(alias_import('nodes'));
import spt.bss.multicombi.multicombi;
import meegpipe.node.pipeline.basic;
import misc.process_arguments;
import misc.split_arguments;
import misc.isnatural;

if nargin < 1 || isempty(sr) || ~isnatural(sr),
    error('The data sampling rate must be provided');
end

opt.FixNbICs = @(x)round(prctile(x,75));
opt.Chopper = chopper.ged('MinChunkLength', 120*250);

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

[~, pipeName] = fileparts(mfilename('fullpath'));


obj = pipeline('NodeList', ...
    {...
    basic(sr), ...
    qrs_detect, ...
    chopper('Algorithm', opt.Chopper), ...
    reref.avg, ...
    bss_regr.bcg(round(sr/4), 'BSS', multicombi, 'FixNbICs', opt.FixNbICs)...
    }, ...
    ...
    'Name', pipeName, ...
    'Save', true, ...
    varargin{:});

end