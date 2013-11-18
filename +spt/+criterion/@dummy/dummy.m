classdef dummy < spt.criterion.criterion & goo.verbose & goo.abstract_named_object
    % DUMMY - A dummy selection criterion that selects no components
    
    
    properties
        Negated = false;
    end
    
    
    methods
        
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
        
        function [selected, featVal] = select(obj, ~, tSeries, varargin)
            featVal = zeros(1, size(tSeries, 1));
            selected = false(1, size(tSeries, 1));
            if obj.Negated,
                selected = ~selected;
            end
        end
        
        function obj = not(obj)
            obj.Negated = ~obj.Negated;
        end
        
        function bool = negated(obj)
            bool = obj.Negated;
        end
        
        % Constructor
        function obj = dummy(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            % First input arg can be a feature object
            if isa(varargin{1}, 'spt.feature.feature'),
                varargin = varargin(2:end);
            end
            opt.Negated = false;
            
            obj = set_properties(obj, opt, varargin);
            
        end
        
        
    end
    
    
end