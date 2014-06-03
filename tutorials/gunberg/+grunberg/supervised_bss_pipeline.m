function myPipe = supervised_bss_pipeline(varargin)

import pset.selector.good_data;
import pset.selector.cascade;

nodeList = {};

%% Importer node
myNode = meegpipe.node.physioset_import.new(...
    'Importer', physioset.import.physioset);
nodeList = [nodeList {myNode}];

%% Supervised BSS
% This node is actually a pipeline that may consist of multiple BSS nodes
% with different settings (e.g. BSS algorithm). By default, it consists
% only of one node that uses multicombi as BSS algorithm.
mySelector = pset.selector.sensor_idx(5:32);
mySelector = pset.selector.cascade( ...
    mySelector, ...
    pset.selector.good_data);
myNode = aar.bss_supervised(...
    'DataSelector', mySelector, ...
    'RetainedVar',  99.9999, ...
    'IOReport',     report.plotter.io);
nodeList = [nodeList {myNode}];

%% Export to fieldtrip format
myExporter = physioset.export.fieldtrip;
mySelector = pset.selector.sensor_idx(5:32);
myNode = meegpipe.node.physioset_export.new(...
    'Exporter',     myExporter, ...
    'DataSelector', cascade(mySelector, good_data));
nodeList = [nodeList {myNode}];

myPipe = meegpipe.node.pipeline.new(...
    'NodeList', nodeList, ...
    'Name',     'supervised-bss', ...
    'Save',     true);


end