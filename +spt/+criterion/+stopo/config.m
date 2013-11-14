classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for stopo criterion
    %
    %
    % See also: stopo
   
    properties
        
        Criterion;
        
    end
    
    % Consistency checks
    
    methods
       
        function obj = set.Criterion(obj, value)
           
            import exceptions.*
            
            if numel(value) ~= 1 || ...
                    ~isa(value, 'spt.criterion.criterion'),
                throw(InvalidPropValue('Criterion', ...
                    'Must be a spt.criterion.criterion object'));
            end
            
            obj.Criterion = value;
            
        end
        
        
    end
        
  
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end