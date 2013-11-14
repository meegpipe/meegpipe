classdef config < spt.criterion.abstract_config
    % CONFIG - Configuration for rank criterion
    %
    % See: <a href="matlab:misc.md_help('spt.criterion.rank.config')">misc.md_help(''spt.criterion.rank.config'')</a>
    
    
    properties        
       
        MaxCard     = Inf;
        MinCard     = 0;
        Min         = -Inf;
        Max         = Inf;        
        Filter      = [];
        
    end
    
     % Consistency checks
    methods
        
         function obj = set.Filter(obj, value)
            import exceptions.*
            
            if isempty(value),
                obj.Filter = [];
                return;
            end
            
            if (numel(value) > 1 || ...
                    ~isa(value, 'filter.dfilt') && ...
                    ~isa(value, 'function_handle')),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.dfilt object or function_handle'));
            end
            obj.Filter = value;                
            
         end      
     
    end
    
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.abstract_config(varargin{:});            
          
            
        end
        
    end
    
    
    
end