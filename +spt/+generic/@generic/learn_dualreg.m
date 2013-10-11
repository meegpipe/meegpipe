function obj = learn_dualreg(obj, data, varargin)
% Learn spatial transform basis using dual regression

import misc.process_arguments;

opt.normalization = true;

[~, opt] = process_arguments(opt, varargin);

dataConcat = cell2mat(data);

obj = learn(obj, dataConcat);
obj.Ai = cell(1, numel(data));
obj.Wi = cell(1, numel(data));

for datasetItr = 1:numel(data)
    
   Sest = pinv(obj.A)*data{datasetItr};
   if opt.normalization,
      Sest = Sest./repmat(sqrt(var(Sest,[],2)),1,size(Sest,2)); 
   end
   Aest = data{datasetItr}*pinv(Sest);   
   
   obj.Ai{datasetItr} = Aest;
   %obj.Ai{datasetItr} = data{datasetItr}*pinv(obj.W*data{datasetItr});   
   obj.Wi{datasetItr} = pinv(obj.Ai{datasetItr});  
   
end




end