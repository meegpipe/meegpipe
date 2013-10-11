classdef iflow 
   
    properties (SetAccess = protected)
        VAR;
        Surrogator;
        Flow;
        Freq;
        SigTh;
        SigThAvg;
        SigLevel;
    end
    
    properties (Dependent)
       FlowAvg;
    end
    
    % Dependent methods
    methods 
        function value = get.FlowAvg(obj)
           if ~isempty(obj.data),
               value = mean(abs(obj.Flow),3);
           else
               value = [];
           end
        end 
        
    end
    
    % Public interface
    methods
        obj = compute_significance(obj, surrObj, siglevel);       
        obj = plot(obj);
        obj = distance(obj1, obj2, type);  
    end
    
    % To be implemented by children classes
    methods (Abstract)
        obj = compute(obj, varObj); 
    end
    

    
    
end
    
    
    