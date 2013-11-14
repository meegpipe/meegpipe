function obj = bcg_cwr(sr, varargin)
% BCG_CWR - Pipeline for BCG correction using carbon wire regression
%
% ## Usage synopsis:
%
% import meegpipe.node.pipeline.bcg_cwr;
% myPipe = bcg_cwr(sr, 'key', value, ...);
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

if nargin < 1 || isempty(sr) || ~isnatural(sr),
    error('The data sampling rate must be provided');
end

[~, pipeName] = fileparts(mfilename('fullpath'));

obj = pipeline('NodeList', ...
    {...
    pipeline.basic(sr), ... 
    aregr.bcg, ...
    }, ...
    ...
    'Name', pipeName, ...
    'Save', true, ...  
    varargin{:});
    



end