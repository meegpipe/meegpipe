function [d, obj] = filter(obj, x, varargin)

import misc.signal2hankel;
import misc.eta;


verbose = is_verbose(obj) && size(x,1) > 5;
verboseLabel = get_verbose_label(obj);

origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

cca = obj.CCA;
cca = set_verbose(cca, verbose);

cca = learn(cca, x);
d   = proj(cca, x);

selected = false(1, size(d,1));

r = get_component_correlation(cca);

if isa(obj.MaxCorr, 'function_handle'),
    maxTh = obj.MaxCorr(r);
else
    maxTh = obj.MaxCorr;
end
selected(r > maxTh) = true;

if isa(obj.MinCorr, 'function_handle'),
    minTh = obj.MinCorr(r);
else
    minTh = obj.MinCorr;
end
selected(r < minTh) = true;

if obj.TopCorrFirst,
    [~, idx] = sort(r, 'descend');
else
    [~, idx] = sort(r, 'ascend');
end

if isa(obj.MinCard, 'function_handle')
    minCard = obj.MinCard(featVal);
else
    minCard = obj.MinCard;
end
if minCard > 0,
    minCard = min(numel(idx), minCard);
    selected(idx(1:minCard)) = true;
end

if isa(obj.MaxCard, 'function_handle'),
    maxCard = obj.MaxCard(featVal);
else
    maxCard = obj.MaxCard;
end

if maxCard < Inf,
    selected(idx((maxCard+1):end)) = false;
end
cca = select_component(cca, selected);

myFilt = obj.ComponentFilter;
if isa(myFilt, 'function_handle'),
    myFilt = myFilt(x.SamplingRate);
end
if ~isempty(myFilt),
    d = filtfilt(myFilt, d);
end

d   = bproj(cca, d);

goo.globals.set('VerboseLabel', origVerboseLabel);

end