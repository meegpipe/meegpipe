classdef abstract_criterion < ...
        goo.abstract_configurable   & ...
        spt.criterion.criterion     & ...
        goo.verbose                 & ...
        goo.abstract_named_object
    
    
    %% IMPLEMENTATION .....................................................
    properties (SetAccess = private, GetAccess = private)
        
        Negated     = false;
  
    end    
    
    % Consistency checks
    methods
        
        function obj = set.Negated(obj, value)
            
            import exceptions.*
            
            if isempty(value), value = false; end
            if numel(value) > 1 || ~islogical(value),
                throw(InvalidPropValue('Negated', ...
                    'Must be a logical scalar'));
            end
            obj.Negated = value;
        end
        
    end   
    
    
   
    %% PUBLIC INTERFACE ...................................................
    
    % spt.criterion.criterion interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        function bool = negated(obj)
            
            bool = obj.Negated;
            
        end
    
    end    
 
    % Constructor
    methods
        
        function obj = abstract_criterion(varargin)
            
            obj = obj@goo.abstract_configurable(varargin{:});
            
        end
        
    end
    
    
    
end