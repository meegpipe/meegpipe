classdef property_match_selector < physioset.event.abstract_selector
    
    properties
        PropertyValue;
        Negated = false;
    end
    
    methods
        
        function obj = set.Negated(obj, value)
            import exceptions.*;
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Negated', ...
                    'Must be a logical scalar'));
            end
            obj.Negated = value;
            
        end
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        function [evArray, idx] = select(obj, evArray)
            
            if isempty(obj.PropertyValue),
                evArray = [];
                idx = [];
                return;
            end
            
            selected = false(size(evArray));
            
            propNames = keys(obj.PropertyValue);
            propVals  = values(obj.PropertyValue);
            if isempty(propNames),
                evArray = [];
                idx = [];
                return;
            end
            
            isMeta = ~ismember(propNames, fieldnames(physioset.event.event));
            metaPropNames = propNames(isMeta);
            propNames = propNames(~isMeta);
            metaPropVals = propVals(isMeta);
            propVals = propVals(~isMeta);
            
            for i = 1:numel(evArray)
                selected(i) = true;
                for j = 1:numel(propNames)
                    if ~selected(i), break; end
                    propValue = get(evArray(i), propNames{j});
                    selected(i) = selected(i) && ~isempty(propValue) && ...
                        all(propValue == propVals{j});
                end
                for j = 1:numel(metaPropNames)
                    if ~selected(i), break; end
                    metaPropValue = get_meta(evArray(i), metaPropNames{j});
                    selected(i) = selected(i) && ~isempty(metaPropValue) && ...
                        all(metaPropValue == metaPropVals{j});
                end
            end
            
            if obj.Negated,
                selected = ~selected;
            end
            
            evArray = evArray(selected);
            
            idx = find(selected);
            
        end
        
        function obj = property_match_selector(varargin)
            
            obj.PropertyValue = mjava.hash;
            
            if nargin < 1, return; end
            
            for i = 1:2:nargin
                obj.PropertyValue(varargin{i}) = varargin{i+1};
            end
            
        end
        
    end
    
    
end