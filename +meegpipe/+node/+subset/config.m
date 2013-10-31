classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of resample nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.resample.config')">misc.md_help(''meegpipe.node.resample.config'')</a>
    
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        SubsetSelector
        AutoDestroyMemMap = false;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.SubsetSelector(obj, value)
            
            import exceptions.*;
            if isempty(value),
                obj.SubsetSelector = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'pset.selector.selector'),
                throw(InvalidPropValue('SubsetSelector', ...
                    'Must be a selector object'));
            end
            obj.SubsetSelector = value;
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end