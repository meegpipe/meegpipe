function myPipe = create_pipeline(varargin)


nodeList = {};

myNode = meegpipe.node.physioset_import.new(...
    'Importer',     physioset.import.eeglab);
nodeList = [nodeList, {myNode}];

myNode = meegpipe.node.filter.new(...
    'Filter', @(sr) filter.hpfilt('fc', 0.2/(sr/2)));
nodeList = [nodeList, {myNode}];

% myNode = meegpipe.node.bad_channels.new;
% nodeList = [nodeList, {myNode}];
myRejCrit = meegpipe.node.bad_channels.criterion.var.new(...
    'Max', @(x) median(x) + mad(x));
myNode = meegpipe.node.bad_channels.new('Criterion', myRejCrit);
nodeList = [nodeList, {myNode}];

myNode = meegpipe.node.bad_epochs.sliding_window(1, 2);
nodeList = [nodeList, {myNode}];

myNode = meegpipe.node.smoother.new;
nodeList = [nodeList, {myNode}];

myNode = aar.pwl.new('IOReport', report.plotter.io);
nodeList = [nodeList, {myNode}];

myNode = aar.sensor_noise.new;
nodeList = [nodeList, {myNode}];

% myNode = aar.ecg.new;
% nodeList = [nodeList, {myNode}];

myNode = aar.eog.new('IOReport', report.plotter.io);
nodeList = [nodeList, {myNode}];

myNode = meegpipe.node.filter.new(...
    'Filter', @(sr) filter.lpfilt('fc', 40/(sr/2)));
nodeList = [nodeList, {myNode}];

myPipe = meegpipe.node.pipeline.new(...
    'NodeList', nodeList, ...
    'Name',     'klaus_tutorial', ...
    'Save',     true, ...
    varargin{:} ...
    );


end