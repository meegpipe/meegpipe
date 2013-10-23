function write_qrs_annot(fName, qrs, sr)

import safefid.safefid;

fid = safefid.fopen(fName, 'w');
[nbMins, nbSecs, nbMSecs] = sample2time(qrs, sr);
fieldLength = 2*round(log10(max(qrs)));
fmt = ['%0.2d:%0.2d.%0.3d\t%' num2str(fieldLength) 'd\t\tN\t0\t0\t0\n'];
for i = 1:numel(qrs)
   
   fprintf(fid, fmt, nbMins(i), nbSecs(i), nbMSecs(i), qrs(i)); 
end


end


function [nbMins, nbSecs, nbMSecs] = sample2time(qrs, sr)

time = qrs/sr;

% # of mins, secs and msecs
nbMins = floor(time/60);
time = time - nbMins*60;
nbSecs = floor(time);
time = time - nbSecs;
nbMSecs = round(time*1000);

end