classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for bad channels rejection criterion rank
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.criterion.rank')">misc.md_help(''meegpipe.node.bad_channels.criterion.rank'')</a>
    
    
    properties
        
        MinCard     = 0;
        MaxCard     = @(dim) ceil(0.2*dim);
        Min         = @(x) median(x)-10*mad(x);
        Max         = @(x) median(x)+10*mad(x);
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.MaxCard(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                obj.MaxCard = @(dim) ceil(0.2*dim);
                return;
            end
            
            if numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('MaxCard', ...
                    'Must be a natural scalar or function_handle'));
            end
            
            obj.MaxCard = value;
            
        end
        
        function obj = set.MinCard(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                obj.MinCard = 0;
                return;
            end
            
            if numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('MinCard', ...
                    'Must be a natural scalar of function_handle'));
            end
            
            obj.MinCard = value;
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
            
        end
        
    end
    
    
    
end