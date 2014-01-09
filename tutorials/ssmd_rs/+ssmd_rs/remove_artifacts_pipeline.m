function myPipe = remove_artifacts_pipeline(varargin)
% REMOVE_ARTIFACTS_PIPELINE - Remove PWL, ECG and EOG artifacts
%
% Note that his pipeline is HUGE. For illustration purposes I have put here
% lost of nodes so that you know what they can be used for. In a real
% application you should aim to have shorter pipelines
%
% See also: batman

import physioset.event.class_selector;
import pset.selector.sensor_label;

% Initialize the list of nodes that the pipeline will contain
nodeList = {};

%% Node 1: data import
myImporter = physioset.import.physioset;
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: copy
myNode = meegpipe.node.copy.new;
nodeList = [nodeList {myNode}];

%% Node 3: PWL removal
myNode = meegpipe.node.bss.pwl;
nodeList = [nodeList {myNode}];

%% Node 4: ECG removal
myNode = meegpipe.node.bss.ecg;
nodeList = [nodeList {myNode}];

%% Node 5: EOG removal
% This a "generic" EOG removal node that does not use any information
% regarding the topography of the components. It simply tries removes any
% component that:
% (1) is large when backprojected at the sensors (ocular activity is large)
% (2) concentrates much more power in the very low frequencies than in
% bands where typical EEG rhythms occur
myNode = meegpipe.node.bss.eog;
nodeList = [nodeList {myNode}];

%% Node 6: EOG removal using an alternative criterion
% This criterion will work (if it works) only with EGI's 256 sensor net. It
% uses a-priori knowledge regarding the net to try to identify ocular
% components. We also include the psd_ratio feature to prevent focussing
% our interest in components that may have the right topography but that
% project negligible energy back at the sensors. This is based on the
% assumption that EOG activity should account for quite a lot of variance
% in the relevant sensors.
myFeat1 = spt.feature.bp_var;
myFeat2 = spt.feature.topo_ratio.eog_egi256_hcgsn1;
myCrit  = spt.criterion.threshold(...
    'Feature', {myFeat1, myFeat2}, ...
    'Max',     {15, @(rankVal) prctile(rankVal, 85)}, ...
    'MaxCard', 4, ...
    'MinCard', 1 ...
    );
myNode = meegpipe.node.bss.eog('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 7: EOG removal (again) using yet another set of features
% We now include also a feature that measures the "complexity" of the
% component time activation. We would expect ocular activity to have low
% complexity, i.e. high fractal dimensions (tfd feature).
myFeat1 = spt.feature.bp_var;
myFeat2 = spt.feature.psd_ratio.eog;
myFeat3 = spt.feature.tfd; 
myCrit  = spt.criterion.threshold(...
    'Feature', {myFeat1, myFeat2, myFeat3}, ...
    'Max',     {15, 15, @(rankVal) prctile(rankVal, 75)}, ...
    'MaxCard', 4, ...
    'MinCard', 1 ...
    );
myNode = meegpipe.node.bss.eog('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%% Node 8: Removal of components with abnormally regular activations
% This is a way of getting rid of noise sources of unknown origin but that
% are clearly not of cerebral origin for having too "simple" or regular
% temporal activations. 
myNode = meegpipe.node.bss.lasip_fit;
nodeList = [nodeList {myNode}];

%% Note 9: Sparse sensor noise removal
% This is an experimental node that tries to remove noise sources that are
% concentrated in a small set of sensors (i.e. sources that are spatially
% "sparse"). Such noise maybe due to a bad contact of a given sensor
% with the scalp. Or due to an active muscle group being located near that
% particular sensor, thus contaminating it with continuous EMG. 
myNode = meegpipe.node.bss.sparse_sensor_noise;
nodeList = [nodeList {myNode}];

%% Node 10: EMG removal (using a filter node)
% We try to minimize EMG artifacts using a CCA (Canonical Correlation
% Analysis filter). This is an experimental node, that has not been 
% extensively tested yet. It is intended to remove burst of EMG activity 
% rather than continuous EMG noise. For details on the CCA algorithm see:
%
% De Clercq, W. et al., Canonical Correlation Analysis Applied to Remove
% Muscle Artifacts from the Electroencephalogram, IEEE Trans. 
% Biomed. Eng 53 (12), pp. 2583-2587. 10.1109/TBME.2006.879459.
myNode = meegpipe.node.filter.emg;
nodeList = [nodeList {myNode}];

%% Create the pipeline
% Note that we set property Save to true. If you wouldn't and your
% processing would take place on the grid (in the background) then your
% processed data would be lost forever...
%
% We are doing something special here. We are wrapping nodes 2 to 7 in
% their own "sub-pipeline". The reason is that we want to generate an
% Input-Output report for that subset of nodes. You cannot generate an
% input-output report from node 1 because the input to node 1 is a file
% name (and not a physioset object).
mySubPipe = meegpipe.node.pipeline.new(...
    'Name',             'ssmd_rs_artifacts', ...
    'NodeList',         nodeList(2:end), ...
    'Save',             false, ...
    'IOReport',         report.plotter.io, ...
    varargin{:});

myPipe = meegpipe.node.pipeline.new(...
    'Name',             'ssmd_rs_artifacts', ...
    'NodeList',         [nodeList(1) {mySubPipe}], ...
    'Save',             true, ...
    varargin{:});

end