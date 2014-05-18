function myPipe = splitting_pipeline(varargin)

nodeList = {};

myNode = meegpipe.node.physioset_import.new(...
    'Importer', physioset.import.physioset);
nodeList = [nodeList; {myNode}];

myEvGen = physioset.event.sleep_scores_generator;
myNode = meegpipe.node.ev_gen.new('EventGenerator', myEvGen);
nodeList = [nodeList; {myNode}];

myEvSel = physioset.event.class_selector('Type', 'Wakefulness');
mySel = pset.selector.event_selector('EventSelector', myEvSel);
myParNode1 = meegpipe.node.subset.new('DataSelector', mySel);

myEvSel = physioset.event.class_selector('Type', 'NREM 1');
mySel = pset.selector.event_selector('EventSelector', myEvSel);
myParNode2 = meegpipe.node.subset.new('DataSelector', mySel);

myNode = meegpipe.node.parallel_node_array.new(...
    'NodeList', {myParNode1, myParNode2});
nodeList = [nodeList; {myNode}];

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',     nodeList, ...
    'Name',         'splitting_pipeline', ...
    varargin{:} ...
    );

end