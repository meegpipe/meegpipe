classdef config < spt.generic.config
    
       
    properties
        AROrder = 10;   
    end         
    
    % Consistency checks
    methods
        
        function obj = set.AROrder(obj, value)
            import exceptions.*;
            import misc.isinteger;            
            
            if numel(value) ~= 1 || ~isinteger(value) || value < 0,
                throw(InvalidPropValue('AROrder', ...
                    'Must be a natural scalar'));
            end
            obj.AROrder = value;            
        end
        
    end
    
    
    methods
       
        function obj = config(varargin)
           
            obj = obj@spt.generic.config(varargin{:});
            
        end
        
        
    end
    
    
    
    
end