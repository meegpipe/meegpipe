classdef config < spt.criterion.abstract_config
    % CONFIG - Configuration for rank criterion
    %
    % See: <a href="matlab:misc.md_help('spt.criterion.rank.config')">misc.md_help(''spt.criterion.rank.config'')</a>
    
    
    properties
        
        Percentile  = [];
        MaxCard     = Inf;
        MinCard     = 0;
        Min         = -Inf;
        Max         = Inf;
        MADs        = [Inf Inf];
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
         
         function obj = set.Percentile(obj, value)
             
            import exceptions.*
            
            if isempty(value),
                obj.Percentile = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isnumeric(value) || value < 0 || ...
                    value > 100
                throw(InvalidPropValue('Percentile', ...
                    'Must be a percentile'));
            end
            
            obj.Percentile = value;
             
         end
         
         function obj = set.MADs(obj, value)
            
             import exceptions.InvalidPropValue;
             
             if isempty(value),
                 obj.MADs = [Inf Inf];
                 return;
             end             
             
             if numel(value) == 1,
                 value = repmat(value, 1, 2);
             end
             
             if numel(value) ~= 2 || ~isnumeric(value),
                 throw(InvalidPropValue('MADs', ...
                     'Must be a 1x2 numeric vector'));
             end
             
             obj.MADs = reshape(value, 1, 2);
             
         end
         
         % more to come...
         
    end
    
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.abstract_config(varargin{:});            
          
            
        end
        
    end
    
    
    
end