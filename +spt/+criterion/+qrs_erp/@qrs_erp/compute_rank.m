function rankValue = compute_rank(obj, ~, data, sr, varargin)

import misc.peakdet;
import misc.eta;
import fmrib.my_fmrib_qrsdetect;
import misc.epoch_get;

WIN_DUR = 30;
NB_WIN = 5;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

off = get_config(obj, 'Offset');
dur = get_config(obj, 'Duration');
srFixed = get_config(obj, 'SamplingRate');

if ~isempty(srFixed),
    sr = srFixed;
end

if verbose,
    fprintf([verboseLabel 'Selecting ECG components ...']);
end

off = -floor(off*sr);
dur = floor(dur*sr);
rankValue = zeros(1, size(data,1));

if verbose,
    tinit = tic;
end

init = 1:(sr*WIN_DUR):size(data,2);
if init(end) < size(data,2),
    init(end) = size(data,2);
end
idx = randperm(numel(init)-1);
idx = idx(1:min(NB_WIN, numel(idx)));

for j = 1:size(data,1)
    
    thisRankValue = nan(1, numel(idx));
    for i = 1:numel(idx)
        thisData = data(j,init(idx(i)):init(idx(i)+1)-1);
        evalc('peakLocs = my_fmrib_qrsdetect(thisData, sr, false)');
        
        if numel(peakLocs) < WIN_DUR/2 || numel(peakLocs) > WIN_DUR*2,    
            thisRankValue(i) = 0;
            continue;
        end
        erp   = epoch_get(thisData, peakLocs, 'Duration', dur, ...
            'Offset', off);
        erp   = squeeze(erp);
        erp   = erp - repmat(mean(erp), size(erp,1), 1);
        erp   = erp./repmat(sqrt(var(erp)), size(erp, 1), 1);
        % Compute xcorr between QRS ERP and individual trials
        erpAvg  = mean(erp, 2);
        erpAvg  = erpAvg - mean(erpAvg);
        erpAvg  = erpAvg./sqrt(var(erpAvg));
        corrVal = erpAvg'*squeeze(erp)/numel(erpAvg);
        rankValue(j) = median(corrVal);
        % The median heart rate must not be too far off, or we penalize the
        % rank value
        medRR = median(diff(peakLocs))/sr;
        if medRR > 1.1,  % 55 bpm
            rankValue(j) = (1-min((medRR-1.1), 1))*rankValue(j);
        end
        if medRR < 0.47, % 128 bpm
            rankValue(j) = (1-min((0.47-medRR)*2, 1))*rankValue(j);
        end

    end
    if verbose,
        eta(tinit, size(data,1), j, 'remaintime', false);
    end
end

if ~isempty(idx) && verbose, fprintf('\n\n'); end



end