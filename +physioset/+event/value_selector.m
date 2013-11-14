classdef value_selector < physioset.event.abstract_selector
    
    properties
        Value = [];
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
        
    end
    
    methods
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        function [evArray, idx] = select(obj, evArray)    
        
            selected = false(size(evArray));
            for i = 1:numel(evArray),
                selected(i) = ~(isempty(evArray(i).Value) || ...
                    ~ismember(evArray(i).Value, obj.Value));
            end
          
            if obj.Negated,
                selected = ~selected;
            end
            
            evArray = evArray(selected);
            
            idx = find(selected);
            
        end
        
        function obj = value_selector(varargin)
           
            if nargin < 1,
                return;
            elseif nargin == 1,
                obj.Value = varargin{1};
            elseif all(cellfun(@(x) isnumeric(x), varargin)),
                obj.Value = cell2mat(varargin);
            else
                obj.Value = varargin;
            end
            
        end
        
    end
    
    
    
    
    
end