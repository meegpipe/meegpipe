function obj = bcg_cwr_mcombi_lasip(sr, varargin)
% BCG_CWR_MCOMBI_LASIP - Pipeline for BCG correction using CWR + 
% multicombi and LASIP filtering
%
% ## Usage synopsis:
%
% import meegpipe.node.pipeline.bcg_cwr_mcombi_lasip;
% myPipe = bcg_cwr_mcombi_lasip(sr, 'key', value, ...);
% data   = run(myPipe, 'myfile.mff');
%
% Where
%
% SR is the sampling rate at the input of the pipeline.
%
%
% ## Accepted key value pairs:
%
%       * All keys accepted by the constructor of class pipeline
%
%       Correction : Percentage. Default: 50
%           A parameter that determines the harshness of the correction:
%           from minimal (0) to maximally harsh (100). 
%
%       MinChunkLength : Natural scalar. Default: 120
%           Minimum analysis window duration in seconds. Use
%           MinChunkLength=Inf to use a single analysis window spanning the
%           whole data duration.
%
% See also: pipeline

import meegpipe.*;
eval(alias_import('nodes'));
import spt.bss.multicombi.multicombi;
import filter.lasip;
import meegpipe.node.pipeline.basic;
import misc.process_arguments;
import misc.split_arguments;
import misc.isnatural;

if nargin < 1 || isempty(sr) || ~isnatural(sr),
    error('The data sampling rate must be provided');
end

opt.Correction     = 50;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

fixNbICs = @(x, y) max(1, round((opt.Correction/100)*y));

[~, pipeName] = fileparts(mfilename('fullpath'));

myFilter = filter.lasip('Gamma', 3:0.1:5, 'Q', 2);

myBCGNode =  bss_regr.bcg(round(sr/4), ...
    'BSS',      multicombi, ...
    'FixNbICs', fixNbICs, ...
    'Filter',   myFilter);

obj = pipeline('NodeList', ...
    {...
    basic(sr), ...
    aregr.bcg, ...
    qrs_detect, ...
    myBCGNode, ...
    }, ...
    ...
    'Name', pipeName, ...
    varargin{:});

end