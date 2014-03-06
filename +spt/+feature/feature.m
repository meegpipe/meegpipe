classdef feature < goo.abstract_named_object
   
    methods (Abstract)
       
        [feature, featName] = extract_feature(obj, sptObj, sptAct, ...
            data, rep, varargin);
        
    end    
     
end