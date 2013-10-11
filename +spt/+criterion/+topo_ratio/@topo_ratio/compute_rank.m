function rankValue = compute_rank(obj, sptObj, data, ~, ~, ~, raw, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

sensNumL    = get_config(obj, 'SensorsNumLeft');
sensNumR    = get_config(obj, 'SensorsNumRight');
sensNumMid  = get_config(obj, 'SensorsNumMid');
sensDen     = get_config(obj, 'SensorsDen');
funcDen     = get_config(obj, 'FunctionDen');
funcNum     = get_config(obj, 'FunctionNum');
symm        = get_config(obj, 'Symmetrical');

M = bprojmat(sptObj);

sens = sensors(raw);

if isa(sensNumL, 'function_handle'),
    sensNumL = sensNumL(sens);
end

if isa(sensNumR, 'function_handle'),
    sensNumR = sensNumR(sens);
end

if isa(sensDen, 'function_handle')
    sensDen = sensDen(sens);
end

if isempty(sensNumL),
    numSetL = [];
else
    [~, numSetL] = ismember(sens, sensNumL);
end
if isempty(sensNumR),
    numSetR = [];
else
    [~, numSetR] = ismember(sens, sensNumR);
end
if isempty(sensNumMid),
    numSetM = [];
else
    [~, numSetM] = ismember(sens, sensNumMid);
    numSetM = numSetM(numSetM > 0);
end

if symm,
    isMissingNum = (numSetL < 1 | numSetR < 1);
    numSetL = numSetL(~isMissingNum);
    numSetR = numSetR(~isMissingNum);
else
    numSetL(numSetL < 1) = [];
    numSetR(numSetR < 1) = [];
end

numSet  = unique([numSetL;numSetR;numSetM]);

if isempty(sensDen),
    denSet = true(sens.NbSensors, 1);
else
    denSet = match_label_regex(sens, sensDen);
end

if isempty(numSet),
    warning('topo_ratio:EmptyNumSet', ...
        'No sensor labels match the numerator regex');
    rankValue = ones(1, size(data,1));
    return;
end
if ~any(denSet),
    warning('topo_ratio:EmptyDenSet', ...
        'No sensor labels match the denominator regex');
    rankValue = ones(1, size(data,1));
    return;
end

rankValue = zeros(1, size(data,1));
asymFactor = ones(1, size(data,1));
if symm && ~isempty(numSetL),
    if verbose,
        fprintf([verboseLabel 'Computing asymmetry coefficients ...']);
    end
    tinit = tic;
    
    for sigIter = 1:size(data, 1)
        
        asym = abs(abs(M(numSetL, sigIter)) - abs(M(numSetR, sigIter)))./...
            max(abs([M(numSetL, sigIter) M(numSetR, sigIter)]), [], 2);
        asymFactor(sigIter) = median(1-asym).^2;
        
        if verbose,
            eta(tinit, size(data, 1), sigIter, 'remaintime', false);
        end
        
    end
    if verbose, fprintf('\n\n'); end
elseif symm
    warning('topo_ratio:MissingLRInfo',...
        'Cannot use symmetry if no Left/Right channels are provided');
end

if verbose,
    fprintf([verboseLabel 'Computing ratios ...']);
end

tinit = tic;
for sigIter = 1:size(data, 1)
    
    num = funcNum(M(numSet, sigIter));
    
    den = funcDen(M(denSet, sigIter));
    rankValue(sigIter) = num/den;
    
    if verbose,
        eta(tinit, size(data, 1), sigIter, 'remaintime', false);
    end
    
end
if verbose, fprintf('\n\n'); end

if symm,
    rankValue = rankValue.*asymFactor;
end



end
