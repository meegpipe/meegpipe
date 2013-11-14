function obj = compute_significance(obj, surrObj, siglevel, varargin)

import misc.process_arguments;
import misc.eta;

if nargin < 3 || isempty(siglevel),
    siglevel = 0.05;
end
if nargin < 2 || isempty(surrObj),
   if isempty(obj.Surrogator),
       throw(InvalidInput);
   else
       surrObj = obj.Surrogator;
   end
end

opt.verbose     = true;

[~,opt] = process_arguments(opt, varargin);

siglevel = sort(siglevel,'descend');
    
% number of surrates to generate
ns = ceil((1-siglevel(end))*10^(-log10(siglevel(end))));
obj.SigTh       = zeros(size(siglevel));
obj.SigThAvg    = zeros(size(siglevel));
maxval          = zeros(ns,1);
maxavgval       = zeros(ns,1);
tinit = tic;
for i = 1:ns
    % generate a data surrogate
    tmpVarObj = var_disconnect(obj.VAR);
    
    dummy = surrogate(surrObj, tmpVarObj);
   
   % re-compute the flow index   
   tmpObj = compute(obj, learn(obj.VAR, dummy), obj.Freq);  
   
   data = tmpObj.Flow;
   
   for j = 1:size(data,1)
       data(j,j,:)=0;
   end
   avgdata      = mean(abs(data),3);
   maxavgval(i) = max(avgdata(:));
   maxval(i)    = max(abs(data(:)));  
   if opt.verbose,
    eta(tinit, ns, i);
   end
end
if opt.verbose,
    fprintf('\n');
end

maxavgval = sort(maxavgval);
maxval = sort(maxval);
for i = 1:length(siglevel)-1
   nsi             = ceil(siglevel(i)*ns);
   obj.SigTh(i)    = maxval(nsi);
   obj.SigThAvg(i) = maxavgval(nsi);
end
obj.SigThAvg(end)   = maxavgval(end);
obj.SigTh(end)      = maxval(end);
obj.SigLevel        = siglevel;
obj.Surrogator      = surrObj;



