% Main tutorial script

urlwrite('http://kasku.org/data/meegpipe/eeglab_data_epochs_ica.set', ...
    'eeglab_data_epochs_ica.set');

myPipe = tutorial_eog.create_pipeline;

cleanedData = run(myPipe, 'eeglab_data_epochs_ica.set');

origData = import(physioset.import.eeglab, 'f1_750to810.set');

plot(origData, cleanedData);