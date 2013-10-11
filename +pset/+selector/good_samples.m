classdef good_samples < pset.selector.abstract_selector
    % GOOD_SAMPLES - Selects good data samples
    %
    %
    % See also: good_data
    
    %% IMPLEMENTATION 
    
    properties (SetAccess = private, GetAccess = private)        
     
        Negated             = false;
        
    end
    
    
    %% PUBLIC INTERFACE ....................................................
   
    % pset.selector.selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = true;
            
        end
        
        function data = select(obj, data, remember)
            
            if nargin < 3 || isempty(remember),
                remember = true;
            end
            
            if obj.Negated,
                
                select(data, 1:size(data,1), is_bad_sample(data), ...
                    remember);
                
            else
                
                select(data, 1:size(data,1), ~is_bad_sample(data), ...
                    remember);
                
            end
           
        end                
        
    end
    
    % Public methods declared and defined here
    
    methods
        
        function disp(obj)
            
            import goo.disp_class_info;
           
            disp_class_info(obj);
           
            if obj.Negated,
                fprintf('%20s : yes\n', 'Negated');
            else
                fprintf('%20s : no\n', 'Negated');
            end
            
        end        
        
    end
    
    
    
end