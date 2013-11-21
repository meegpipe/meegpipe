classdef linear_combination < spt.feature.feature & goo.verbose
    % LINEAR_COMBINATION - Linear combination of features
    
    
    properties
        Weights  = []; % To be applied to the time-series before the HT
        Features = {}; % Cell array of features
    end
    
    % Consistency checks
    methods
        
        function check(obj)
           import exceptions.Inconsistent;
           
           if (~isempty(obj.Features) || ~isempty(obj.Weights)) && ...
                   numel(obj.Features) ~= numel(obj.Weights),
               throw(Inconsistent(...
                   'Number of weights must match number of features'));
           end            
            
        end
        
        function obj = set.Features(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Feature = {};
                return;
            end
            
            if ~iscell(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) isa(x, 'spt.feature.feature'), value)),
                throw(InvalidPropValue('Feature', ...
                    'Must be a cell array of spt.feature.feature'));
            end
            obj.Features = value;            
        end
        
        function obj = set.Weights(obj, value)
           import exceptions.InvalidPropValue;
           
           if isempty(value),
               obj.Weights = [];
               return;
           end
           
           if ~isnumeric(value),
               throw(InvalidPropValue('Weights', ...
                   'Must be a vector of numeric weights'));
           end
           obj.Weights = value;
           
        end
        
    end
    
    methods
        
        % spt.feature.feature interface
        function featVal = extract_feature(obj, varargin)
            
            featVal = obj.Weights(1)*extract_feature(obj.Features{1}, ...
                varargin{:});
            for i = 2:numel(obj.Features)
                featVal = featVal + ...
                    obj.Weights(i)*extract_feature(obj.Features{i}, ...
                    varargin{:});
            end
            
        end
        
        % Constructor
        function obj = linear_combination(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Weights  = [];
            opt.Features = {};
            obj = set_properties(obj, opt, varargin);
            
            check(obj);
            
        end
        
    end
    
    
    
end