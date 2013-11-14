function rankValue = compute_rank(obj, ~, data, sr, ~, ~, raw, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;

if nargin < 4 || isempty(sr),
    if pkgisa(raw, 'physioset'),
        sr = raw.SamplingRate; 
    else
        error('narrowband:UnknownSamplingRate', ...
            'The data sampling rate must be provided');
    end
end


verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

band1       = get_config(obj, 'Band1');
band2       = get_config(obj, 'Band2');
stat1       = get_config(obj, 'Band1Stat');
stat2       = get_config(obj, 'Band2Stat');
estimator   = get_config(obj, 'Estimator');

hpsd  = cell(size(data, 1), 1);
tinit = tic;
if verbose,
    fprintf([verboseLabel 'Computing narrowband criterion ...']);
end

for sigIter = 1:size(data,1)
    
    if pkgisa(data, 'physioset') && is_bad_channel(data, sigIter),
        
        % do nothing
        
    else
        
        [hpsd{sigIter}, freqs] = estimator(data(sigIter,:), sr);  
        
    end
    
    if verbose,
        eta(tinit, size(data, 1), sigIter, 'remaintime', false);
    end
    
end

if verbose,
    fprintf('\n\n');
end

if verbose,
    fprintf([verboseLabel ' Computing spectral ratios...']);
end

rankValue = zeros(1, size(data,1));

for sigIter = 1:size(data, 1)
    
    if isempty(hpsd{sigIter}),
        % Ignore bad channels
        
    else
        
        % Normalized PSD
       
        pf  = hpsd{sigIter};
        pf  = pf./sum(pf);
        
        % Calculate power in band of interest
        narrowBandPower = 0;
        for bandItr = 1:size(band1, 1)
            f0  = band1(bandItr, 1);
            f1  = band1(bandItr, 2);
            isInBand        = freqs>= f0 & freqs<=f1;
           
            narrowBandPower = narrowBandPower + stat1(pf(isInBand));
        end
        
        % Calculate power in the "other" band
        otherPower = 0;
        for bandItr = 1:size(band2, 1)
            f02  = band2(bandItr, 1);
            f12  = band2(bandItr, 2);
            isOtherBand     = freqs>= f02 & freqs<=f12;
            
            otherPower      = otherPower + stat2(pf(isOtherBand));
        end
        
        rankValue(sigIter) = narrowBandPower/otherPower;        
    
    end    
    
    if verbose,
        eta(tinit, size(data, 1), sigIter, 'remaintime', false);
    end
    
end

if verbose, fprintf('\n\n'); end

end