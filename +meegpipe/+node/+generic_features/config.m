classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of erp nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.erp.config')">misc.md_help(''meegpipe.node.erp.config'')</a>
    
    
    properties
        
        TargetSelector    = [];
        FirstLevel        = {@(x, ev, dataSel) mean(x)};
        SecondLevel       = [];
        FeatureNames      = {'mean'};
        
    end
    
    % Consistency checks
    
    methods (Access = private)
        
        function global_check(obj)
            import exceptions.Inconsistent;
            
            if isempty(obj.SecondLevel),
                if numel(obj.FeatureNames) ~= numel(obj.FirstLevel),
                    
                    throw(Inconsistent(['Number of feature names does not ' ...
                        'match number of first level features']));
                    
                end
                
            elseif ~isempty(obj.SecondLevel)
                
                if ~all(size(obj.FeatureNames) == ...
                        [numel(obj.FirstLevel) numel(obj.SecondLevel)]),
                    
                    throw(Inconsistent(sprintf([...
                        'Property FeatureNames must have dimensions ' ...
                        '[%d %d]'], numel(obj.FirstLevel), ...
                        numel(obj.SecondLevel))));
                    
                end
                
            end
            
        end
        
    end
    
    methods
        
        function obj = set.TargetSelector(obj, value)
            
            import exceptions.InvalidPropValue;
            
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
        
        function obj = set.FirstLevel(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.FirstLevel = [];
                return;
            end
            
            if ~iscell(value), value = {value}; end
            
            if ~all(cellfun(@(x) isa(x, 'function_handle'), value))
                throw(InvalidPropValue('FirstLevel', ...
                    'Must be a cell array of function_handle'));
            end
            
            obj.FirstLevel = value;
        end
        
        function obj = set.SecondLevel(obj, value)
            import exceptions.InvalidPropValue;
            if isempty(value),
                obj.SecondLevel = [];
                return;
            end
            
            if ~iscell(value), value = {value}; end
            
            if ~all(cellfun(@(x) isa(x, 'function_handle'), value))
                throw(InvalidPropValue('SecondLevel', ...
                    'Must be a cell array of function_handle'));
            end
            
            obj.SecondLevel = value;
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
            global_check(obj);
            
        end
        
    end
    
    
end