function myPipe = create_pipeline(varargin)


nodeList = {};
myNode = meegpipe.node.physioset_import.new(...
    'Importer',     physioset.import.eeglab);
nodeList = [nodeList, {myNode}];

myNode = aar.pwl.new('IOReport', report.plotter.io);
nodeList = [nodeList, {myNode}];

myNode = aar.sensor_noise.new;
nodeList = [nodeList, {myNode}];

myNode = aar.ecg.new;
nodeList = [nodeList, {myNode}];

myNode = aar.eog.new('IOReport', report.plotter.io);
nodeList = [nodeList, {myNode}];

myPipe = meegpipe.node.pipeline.new(...
    'NodeList', nodeList, ...
    'Name',     'klaus_tutorial', ...
    'Save',     true, ...
    varargin{:} ...
    );


end