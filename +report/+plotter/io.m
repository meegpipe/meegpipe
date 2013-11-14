function obj = io(varargin)
% IO - Constructor of input/output reports
%
% import report.plotter.io;
% obj = io('key', value, ...)
%
% ## Accepted construction arguments:
%
%       Snapshots : boolean. Default: true
%           If set to true, snapshots of both input and output will be
%           generated.
%
%       PSD : boolean. Default: true
%           If set to true, snapshots of both input and output will be
%           generated.
%
%       FreqRange : A 1x2 numeric matrix. Default: [0 60]
%           Frequency range for the PSD plots, in Hz.
%
%       BOIs : mjava.hash. Default: plotter.psd.eeg_bands('alpha')
%           The Bands of Interest. The relative energy in each of these
%           bands will be computed both for input and output.
%
%       PerBoiPSDs : boolean. Default: false
%           If set to true, a PSD per BOI will be generated. Such PSDs will
%           be scaled so that the BOI power in intput and output is matched
%           as closely as possible. These plots can be useful to identify
%           within-BOI distortions introduced by a processing node.
%
%       
%
% See also: plotter

import report.plotter.plotter;
import physioset.plotter.snapshots.snapshots;
import physioset.plotter.psd.psd;


snapshotPlotter = snapshots(...
    'MaxChannels',  30, ...
    'WinLength',    [10 35], ...
    'NbBadEpochs',  0, ...
    'NbGoodEpochs', 5);

lowLevelPSDPlotter = plotter.psd.psd(...
    'FrequencyRange',   [3 60], ...
    'Visible',          false, ...
    'Transparent',      true, ...
    'LogData',          false ...
    );

psdPlotter = psd(...
    'MaxChannels',  50, ...
    'WinLength',    30, ...
    'Plotter',      lowLevelPSDPlotter); %#ok<FDEPR>


obj = plotter(...
    'Plotter',  {snapshotPlotter, psdPlotter}, ...
    'Title',    'Input/output report');





end