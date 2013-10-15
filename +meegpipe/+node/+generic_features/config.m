classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of erp nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.erp.config')">misc.md_help(''meegpipe.node.erp.config'')</a>
 
    
    properties
        
        TargetSelector    = [];
        FirstLevel        = @(x) mean(x);
        SecondLevel       = @(x) mean(x);
        FeatureNames      = {'mean'};
        
    end
    
    % Consistency checks
    
    methods
        
        function obj = set.TargetSelector(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.TargetSelector = [];
                return;
            end
            
            if ~iscell(value), value = {value}; end
            
            if ~all(cellfun(@(x) isa(x, 'pset.selector.selector'), value))
                throw(InvalidPropValue('TargetSelector', ...
                    'Must be a data selector object'));
            end
            
            obj.TargetSelector = value;            
            
        end        
       
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
end