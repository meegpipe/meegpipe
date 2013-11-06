function featVals = co_features(data, sr)


import cardiac_output.abpfeature;
import cardiac_output.wabp;

% Calibration (this is assumed to have happened already!!)
% STD_PSYS  = 120;
% STD_PDIAS = 80;
% abp = data(1,:)';
% ssf = abp(1:min(sr*10, numel(abp)));
% abp = (STD_PSYS-STD_PDIAS)*(abp - mean(ssf))/range(ssf)+STD_PDIAS;

ABP_SRATE = 125;

% Resample to 125 Hz, what James Sun's cardiac_output functions expect
abp = data(1,:)';
abp = resample(abp, ABP_SRATE, sr);

% Detect beat onsets and extract features for each beat
r = wabp(abp);
out = abpfeature(abp, r);

% Estimate heart rate
t1 = diff(out(:, 1));
t2 = diff(out(:, 3));
t = (t1 + t2)/2;
t = medfilt1(t, 5);
hr = 60./(t/ABP_SRATE);
hr = [hr(1);hr];

% Select relevant columns and remove outliers
out = out(:, [2 4:6 8 10 12]);

out = medfilt1(out, 4);

% HR and CO
out = [out hr (out(:,3)./(out(:,1)+out(:,2))).*hr];

featVals = mean(out);

end