function [data, A] = sample_data()


X = rand(10, 1000);

sensObj = subset(sensors.eeg.from_template('egi256'), 1:10);

A = misc.unit_norm(rand(10));

for i = 1:size(A,2),
    A(:,i) = A(:,i) * (1.5^i);
end

data = import(physioset.import.matrix('Sensors', sensObj), A*X);


end