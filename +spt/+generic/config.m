classdef config < ...
        goo.abstract_setget_handle & ...
        goo.reportable_handle
    % CONFIG - Configuration for class generic
    
    
    % Configuration options common to all config classes
    properties
        
        Filter       = [];
        EmbedDim     = 1;
        DataSelector = [];
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Filter(obj, value)
            
            import spt.generic.generic;
            import exceptions.*;
            
            if isempty(value) || ...
                    (isnumeric(value) && numel(value) == 1 && isnan(value)),
                obj.Filter = [];
                return;
            end
            
            if isa(value, 'function_handle'), 
                % Function handle must take one input argument: sr
                try
                    value(1000);
                catch ME
                    if strcmp(ME.identifier, 'MATLAB:TooManyInputs'),
                        throw(InvalidPropValue('Filter', ...
                            'function_handle must accept one input argument'));
                    else
                        rethrow(ME);
                    end
                end
                    
                
            elseif ~isa(value, 'filter.dfilt'),
                
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.dfilt object'));
         
            end
            
            obj.Filter =  value;
            
        end
        
        function obj = set.EmbedDim(obj, value)
            
            import spt.generic.generic;
            import misc.isnatural;
            import exceptions.*
            
            if ~isempty(value) && (numel(value)>1 || ~isnatural(value)),
                
                throw(InvalidPropValue('Filter', ...
                    'Must be a natural scalar'));
                
            elseif isempty(value),
                
                value = 1;
            end
            
            obj.EmbedDim =  value;
            
        end
        
        function obj = set.DataSelector(obj, value)
            
            import exceptions.*
            
            if isempty(value),
                obj.DataSelector = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'pset.selector.selector'),
                throw(InvalidPropValue('DataSelector', ...
                    'Must be a selector object'));
            end
            
            obj.DataSelector = value;
            
            
        end
        
    end

 
    methods
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});
            
        end
    end
    
end