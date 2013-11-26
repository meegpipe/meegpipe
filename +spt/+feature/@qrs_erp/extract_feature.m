function featVal = extract_feature(obj, ~, tSeries, data, varargin)

import misc.peakdet;
import misc.eta;
import fmrib.my_fmrib_qrsdetect;
import misc.epoch_get;

% Duration and number of sample analysis windows
WIN_DUR = 40; % In seconds
NB_WIN  = 10;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

if nargin < 4 || isempty(data),
    sr = tSeries.SamplingRate;
else
    sr = data.SamplingRate;
end

if ~isempty(obj.Filter)
    if verbose,
        fprintf([verboseLabel ...
            'Pre-filtering before extracting qrs_erp features ...\n\n']);
    end
    if isa(tSeries, 'pset.mmappset'),
        tSeries = copy(tSeries);
    end
    
    if isa(obj.Filter, 'function_handle'),
        filtObj = obj.Filter(sr);
    else
        filtObj = obj.Filter;
    end
    
    tSeries = filter(filtObj, tSeries);
end

if verbose,
    fprintf([verboseLabel 'Extracting qrs_erp features ...']);
end

off = -floor(obj.Offset*sr);
dur = floor(obj.Duration*sr);

% Onset of the NB_WIN sample windows that will be used as a representative
% sample of the whole dataset. Important: Do not pick windows randomly as
% that would prevent reproducing any results that use qrs_erp features.
winDur = sr*WIN_DUR;
init = 1:winDur:size(tSeries,2)-winDur;
if isempty(init), init = 1; end
idx  = round(linspace(1, numel(init), NB_WIN + 1));
idx  = unique(idx);
init = init(idx);

if verbose, tinit = tic; end
featVal = zeros(size(tSeries,1), 1);
for j = 1:size(tSeries,1)
    
    winStatVal = nan(1, numel(init));
    for i = 1:numel(init)
        winData = tSeries(j, init(i):min(init(i)+winDur, size(tSeries,2)));
        evalc('peakLocs = my_fmrib_qrsdetect(winData, sr, false)');
        
        if numel(peakLocs) < WIN_DUR/2 || numel(peakLocs) > WIN_DUR*2,
            winStatVal(i) = 0;
            continue;
        end
        
        erp   = epoch_get(winData, peakLocs, ...
            'Duration', dur, ...
            'Offset',   off);
        
        % Normalize epochs to have zero mean and unit variance
        erp   = squeeze(erp);
        erp   = erp - repmat(mean(erp), size(erp,1), 1);
        erp   = erp./repmat(sqrt(var(erp)), size(erp, 1), 1);
         
        % Compute xcorr between ERP and individual trials
        erpAvg  = mean(erp, 2);
        erpAvg  = erpAvg - mean(erpAvg);
        erpAvg  = erpAvg./sqrt(var(erpAvg));
        corrVal = erpAvg'*squeeze(erp)/numel(erpAvg);
        winStatVal(i) = obj.CorrAggregationStat(corrVal);
        
        % Penalize windows where the median RR is too large or too small
        medRR = median(diff(peakLocs))/sr;
        if medRR > 1.1,  % 55 bpm
            winStatVal(i) = (1-min((medRR-1.1), 1))*winStatVal(i);
        end
        if medRR < 0.47, % 128 bpm
            winStatVal(i) = (1-min((0.47-medRR)*2, 1))*winStatVal(i);
        end
        
    end
    if verbose,
        eta(tinit, size(tSeries,1), j, 'remaintime', false);
    end
    featVal(j) = median(winStatVal);
end

if verbose, fprintf('\n\n'); end


end