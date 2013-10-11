classdef config < spt.generic.config
    % CONFIG - Configuration for class multicombi
    %
    %
    % See also: spt, abstract_spt
    
    % Documentation: pkg_multicombi.txt
    % Description: Configuration for class multicombi
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        AROrder         = 10;
     
    end
    
    % Consistency checks
    methods
        
        function obj = set.AROrder(obj, value)
            
            import exceptions.*
            import misc.isnatural;
            if isempty(value),
                obj.AROrder = 10;
                return;
            end
            
            if numel(value)~=1 || ~isnatural(value),
                throw(InvalidPropValue('AROrder', ...
                   'Must be a natural number'));
            end
            
            obj.AROrder = value;
            
        end
     
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.generic.config(varargin{:});
            
        end
        
    end
    
    
    
end