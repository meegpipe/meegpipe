function myPipeline = artifacts(sr, varargin)
% ARTIFACTS - Remove PWL, ECG, EOG and EMG artifacts from MEG and hdEEG
%
% ## Usage synopsis:
%
% eval(meegpipe.alias_import('nodes'));
% import meegpipe.node.pipeline.artifacts;
% import meegpipe.node.pipeline.basic;
%
% % Typically you will want to do some basic preprocessing before running
% % artifacts pipeline. Thus:
% myPipeline = pipeline('NodeList', ...
%       {pipeline.basic(sr), pipeline.artifacts(round(sr/4))});
% data = run(myPipe, 'myfile.mff');
%
% Where
%
% SR is the sampling rate of the input raw data. Note that the basic
% pipeline above includes a downsampling (by 4) node, which explains the
% different sampling rate provided to the artifacts pipeline.
%
% 
% ## Accepted key/value pairs:
%
%   * All keys accepted by the constructor of class pipeline
%
%
% ## Pipeline description:
%
% The pipeline consists of the following nodes, in this order:
%
% 1) A bss_regr.pwl node which will identify and remove powerline related
%    spatial components using MULTICOMBI [1].
%
% 2) A bss_regr.ecg node which will identify and remove ECG-related
%    MULTICOMBI components.
%
% 3) A bss_regr.eog node which will identify and remove ocular components.
%
% 4) A bss_regr.emg node which will attempt to reject spatial components
%   associated with long duration EMG artifacts. 
%
%
% ## References:
%
% [1] MULTICOMBI: http://www.germangh.com/papers.html#multicombi
%
%
% See also: pipeline, basic


    import meegpipe.*;
    eval(alias_import('nodes'));
    import meegpipe.node.bss_regr.pwl;
    import meegpipe.node.bss_regr.ecg;
    import meegpipe.node.bss_regr.eog;
    import meegpipe.node.bss_regr.emg;
    import report.plotter.io;
    
    if nargin < 1 || isempty(sr),
        error('The data sampling rate needs to be provided');
    end

    % Node bss_regr is the swiss army knife node that we also use for 
    % removing ECG, EOG, and EMG artifacts. We just need to use the
    % correct default constructor so that the configuration of the bss_regr
    % node suits our specific needs:
    myPipeline = pipeline('NodeList', ...
        {...   
        pwl(sr), ...
        ecg(sr), ...
        eog(sr), ...
        emg(sr), ...
        }, ...
        ...
        'Name',     'Artifact pipeline', ...
        'Save',     true, ...
        'IOReport', io, ...
        varargin{:});
end