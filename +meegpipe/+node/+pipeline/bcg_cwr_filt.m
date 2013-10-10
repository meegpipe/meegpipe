function obj = bcg_cwr_filt(sr, varargin)
% BCG_CWR_FILT - Pipeline for BCG correction using carbon wire regression
%
% ## Usage synopsis:
%
% import meegpipe.node.pipeline.bcg_cwr_filt;
% myPipe = bcg_cwr_filt(sr, 'key', value, ...);
% data   = run(myPipe, 'myfile.mff');
%
% Where
%
%   SR is the sampling rate of the input raw data.
%
%
% ## Accepted key value pairs:
%
%   * All keys accepted by the constructor of class pipeline
%
%
% ## Pipeline description
%
% This pipeline is just a concatenation of pipeline.basic and and an
% aregr.bcg node which will regress out all channels of type CW
% (Carbon-wire) from any EEG channel.
%
%
% See also: pipeline, basic, aregr

import meegpipe.*;
eval(alias_import('nodes'));
import pset.selector.sensor_class;
import filter.mlag_regr;
import report.plotter.plotter;
import misc.isnatural;
import misc.process_arguments;
import misc.split_arguments;

if nargin < 1 || isempty(sr) || ~isnatural(sr),
    error('The data sampling rate must be provided');
end

opt.CWFilter = filter.lasip('Gamma', 3:0.1:5);  

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

[~, pipeName] = fileparts(mfilename('fullpath'));

myCWSel = pset.selector.sensor_class('Type', 'CW');
        
obj = pipeline('NodeList', ...
    {...    
    pipeline.basic(sr), ... 
    tfilter('Filter', opt.CWFilter, 'DataSelector', myCWSel), ...
    aregr.bcg, ...
    }, ...
    ...
    'Name', pipeName, ...
    'Save', true, ...  
    varargin{:});
    



end