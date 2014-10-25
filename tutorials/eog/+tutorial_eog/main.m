% Main tutorial script

if ~exist('eeglab_data_epochs_ica.set', 'file')
    urlwrite('http://kasku.org/data/meegpipe/eeglab_data_epochs_ica.set', ...
        'eeglab_data_epochs_ica.set');
end

myPipe = tutorial_eog.create_pipeline;

cleanedData = run(myPipe, 'eeglab_data_epochs_ica.set');

origData = import(physioset.import.eeglab, 'eeglab_data_epochs_ica.set');

plot(origData, cleanedData);