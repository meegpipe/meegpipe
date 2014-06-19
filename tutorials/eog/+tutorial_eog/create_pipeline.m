function myPipe = create_pipeline(varargin)

myNode1 = meegpipe.node.physioset_import.new(...
    'Importer', physioset.import.eeglab);

myNode2 = aar.eog.regression('Order', 5);

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         {myNode1, myNode2}, ...
    'GenerateReport',   true);

cleanData = run(myPipe, 'eeglab_data_epochs_ica.set');
origData = import(physioset.import.eeglab, 'eeglab_data_epochs_ica.set');
plot(origData, cleanData);

end