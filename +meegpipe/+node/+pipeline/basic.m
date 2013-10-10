function obj = basic(sr, varargin)
% BASIC - A very generic/basic preprocessing pipeline for MEG and hdEEG
%
% ## Usage synopsis:
%
% import meegpipe.node.pipeline.basic;
% myPipe = basic(sr, 'key', value, ...);
% data   = run(myPipe, 'myfile.mff');
%
% % Use neuromag data importer instead of default mff importer
% myPipe = basic(sr, 'Importer', physioset.import.neuromag);
% data   = run(myPipe, 'myfile.fif');
%
% Where
%
% SR is the sampling rate of the input to the pipeline.
%
%
% ## Accepted key value pairs:
%
%   * All keys accepted by the constructor of class pipeline
%
%       Importer : A physioset.import.import object. 
%           Default: physioset.import.mff
%
%       DownSampleBy : An integer. Default: 4
%           The downsampling factor to apply to the input data.
%
%
% ## Pipeline description
%
% The pipeline consists of the following nodes, in this order:
%
% 1) A physioset_import node that will import the M/EEG data from a disk
%    file using the provided data importer.
% 
% 2) A center node, which will remove the data mean
%
% 3) A detrend node, which will remove very low frequency trends using a
%    low-order polynomial fit. This stage might not be necessary in all
%    cases but it is typically necessary when dealing with hdEEG files 
%    recorded with the EGI system.
%
% 4) A resample node, which will downsample the data according to the
%    provided DownSampleBy option.
%
% 5) A high-pass filter with cutoff fc=0.5 Hz
%
% 6) A reref node that will re-reference the data using an average
%    reference.
%
% 7) A bad_channels node that will reject any channel having abnormal
%    variance.
%
% 8) A bad_channels node that will reject channels having abnormally low
%    cross-correlation with neighbouring channels.
%
% 9) A bad_samples node that will reject data epochs with abnormally low or
%    abnormally high variance.
%
%
% ## Notes:
%
% * Stages 7, 8, and 9 above are grouped with a sub-pipeline. This has no
%   other implications than affecting the hierarchical organization of the
%   generated HTML reports.
%
%
% See also: pipeline, artifacts

import meegpipe.*;
eval(alias_import('nodes'));
import physioset.import.mff;
import report.plotter.plotter;
import meegpipe.node.bad_channels.*;
import misc.split_arguments;
import misc.process_arguments;
import misc.isnatural;

if nargin < 1 || isempty(sr),
    sr = NaN;
end

if ischar(sr),
    varargin = [{sr} varargin];
    sr = NaN;
end

opt.Importer      = mff;
opt.OutputRate    = 250;
opt.PercentileBad = [3 95];

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

[~, pipeName] = fileparts(mfilename('fullpath'));

crit2 = criterion.xcorr.xcorr;
crit1 = criterion.var.var('Percentile', opt.PercentileBad);

if isnan(sr),
    myFilter = @(sr) filter.bpfilt('Fp', [0.5 sr/2]/(sr/2));
else
    myFilter = filter.bpfilt('Fp', [0.5 sr/2]/(sr/2));
end

badDataPipe = pipeline('NodeList', ...
    {...
    bad_channels('Criterion', crit1), ...
    bad_channels('Criterion', crit2), ...
    bad_samples}, ...
    'Name', 'bad_data');

%badDataPipe, ...
obj = pipeline('NodeList', {...
    physioset_import('Importer', opt.Importer), ...
    tfilter.detrend, ...
    resample('OutputRate', opt.OutputRate), ... 
    tfilter('Filter', myFilter), ...
    badDataPipe ...
    }, ...
    ...
    'Name', pipeName, ...
    'Save', true, ...
     varargin{:});


end
