function data = calibrate_abp(data)
% CALIBRATE_ABP - Calibrates ABP signal so that it is in mmHg

STD_PSYS  = 120;
STD_PDIAS = 80;
abp = data(1,:)';

% Discard first and last sample where weird stuff tends to happen
firstSample = ceil(0.1*size(data,2));
lastSample  = ceil(0.9*size(data,2));
ssf = abp(firstSample:lastSample);

% Discard outliers in a very crude way
ssfMedian = median(ssf);
ssf(ssf>ssfMedian+20*mad(ssf)) = ssfMedian+20*mad(ssf);
ssf(ssf<ssfMedian-10*mad(ssf)) = ssfMedian-5*mad(ssf);
abp(abp>ssfMedian+20*mad(ssf)) = ssfMedian+20*mad(ssf);
abp(abp<ssfMedian-5*mad(ssf)) = ssfMedian-5*mad(ssf);

% Flat-out the first and last samples (we loose 3% of data)
abp(1:ceil(0.015*size(data,2)))=ssfMedian;
abp(end-ceil(0.015*size(data,2)):end)=ssfMedian;

abp = (STD_PSYS-STD_PDIAS)*(abp - mean(ssf))/range(ssf)+STD_PDIAS;

data(1,:) = abp';

end