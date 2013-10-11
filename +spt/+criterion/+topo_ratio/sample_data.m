function [data, A] = sample_data()


X = rand(10, 1000);

sensObj = subset(sensors.eeg.from_template('egi256'), 1:10);

A = misc.unit_norm(rand(10));

A = A + diag(10*max(A(:))*ones(1, size(A,1)));

data = import(physioset.import.matrix('Sensors', sensObj), A*X);


end