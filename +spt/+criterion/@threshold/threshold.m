classdef threshold < spt.criterion.criterion & goo.verbose
    % THRESHOLD - Select components that exceed a threshold
    
    
    properties
        Negated = false;
        Feature = [];;
        Min     = -Inf;
        Max     = +Inf;
        MinCard = 0;
        MaxCard = Inf;
    end
    
    
    methods
        %% Consistency checks
        function obj = set.Negated(obj, value)
            import exceptions.InvalidPropValue;
            if isempty(value),
                obj.Negated = false;
                return;
            end
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Negated', ...
                    'Must be a logical scalar'));
            end
            obj.Negated = value;
        end
        
        function obj = set.Feature(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Feature = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'spt.feature.feature'),
                throw(InvalidPropValue('Feature', ...
                    'Must be a spt.feature.feature'));
            end
            obj.Feature = value;
            
        end
        
        
        %% spt.criterion.criterion interface
        [selected, featVal] = select(obj, objSpt, tSeries, varargin)
        
        function obj = not(obj)
            obj.Negated = ~obj.Negated;
        end
        
        function bool = negated(obj)
            bool = obj.Negated;
        end
        
        %% Constructor
        function obj = threshold(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Negated = false;
            opt.Feature = [];
            opt.Min     = -Inf;
            opt.Max     = +Inf;
            opt.MinCard = 0;
            opt.MaxCard = Inf;
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
    
    
end