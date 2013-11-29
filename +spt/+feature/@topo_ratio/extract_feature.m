function featVal = extract_feature(obj, sptObj, tSeries, data, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

sensNumL    = obj.SensorsNumLeft;
sensNumR    = obj.SensorsNumRight;
sensNumMid  = obj.SensorsNumMid;
sensDen     = obj.SensorsDen;
funcDen     = obj.FunctionDen;
funcNum     = obj.FunctionNum;
symm        = obj.Symmetrical;

M = bprojmat(sptObj);

sens = sensors(data);

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
    featVal = ones(size(tSeries,1), 1);
    return;
end
if ~any(denSet),
    warning('topo_ratio:EmptyDenSet', ...
        'No sensor labels match the denominator regex');
    featVal = ones(size(tSeries,1), 1);
    return;
end

featVal = zeros(size(tSeries,1), 1);
asymFactor = ones(1, size(tSeries,1));
if symm && ~isempty(numSetL),
    if verbose,
        fprintf([verboseLabel 'Computing asymmetry coefficients ...']);
    end
    tinit = tic;
    
    for sigIter = 1:size(tSeries, 1)
        
        asym = abs(abs(M(numSetL, sigIter)) - abs(M(numSetR, sigIter)))./...
            max(abs([M(numSetL, sigIter) M(numSetR, sigIter)]), [], 2);
        asymFactor(sigIter) = median(1-asym).^2;
        
        if verbose,
            eta(tinit, size(tSeries, 1), sigIter, 'remaintime', false);
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
for sigIter = 1:size(tSeries, 1)
    
    num = funcNum(M(numSet, sigIter));
    
    den = funcDen(M(denSet, sigIter));
    featVal(sigIter) = num/den;
    
    if verbose,
        eta(tinit, size(tSeries, 1), sigIter, 'remaintime', false);
    end
    
end
if verbose, fprintf('\n\n'); end

if symm,
    featVal = featVal(:).*asymFactor(:);
end

end
