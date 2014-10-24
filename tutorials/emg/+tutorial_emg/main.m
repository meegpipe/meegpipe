% Main tutorial script

if ~exist('f1_750to810.set', 'file')
    urlwrite(...
        'http://dl.dropboxusercontent.com/u/4479286/meegpipe/f1_750to810.set', ...
        'f1_750to810.set');
end

myPipe = tutorial_emg.create_pipeline;

cleanedData = run(myPipe, 'f1_750to810.set');

origData = import(physioset.import.eeglab, 'f1_750to810.set');

plot(origData, cleanedData);