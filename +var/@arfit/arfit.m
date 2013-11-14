classdef arfit < var.algorithm
    % ARFIT - VAR estimation algorithm ARFIT [1]
    %
    %
    % obj = var.arfit('key', value, ...);
    % A = learn_coeffs(obj, data);
    %
    %
    % Where
    %
    %
    % DATA is a numeric data matrix to which the VAR model will be fit.
    % Observations are columnwise, i.e. DATA is a D x K matrix with K
    % observations of a D-dimensional data generating process.
    %
    % A are the estimated VAR model coefficients: a D x (D x P) matrix
    %
    %
    % ## References:
    %
    % [1] ARFIT: http://www.gps.caltech.edu/~tapio/arfit/
    %
    %
    % See also: var.estimator
    
    % Documentation: class_var_arfit.txt
    % Description: VAR estimation using ARFIT
    
    % Exceptions
    methods (Static, Access =private)
        function obj = InvalidPropValue(prop, msg)
           if nargin < 1 || isempty(prop), prop = '??'; end
           if nargin < 2 || isempty(msg), msg = ''; end
           msg = sprintf('Invalid ''%s'': %s', prop, msg);
           obj = MException('var:arfit:InvalidPropValue', msg);
        end
    end
    
    
    % Public interface ....................................................
    properties
        MinOrder;
        MaxOrder;
        OrderCriterion;
        ForceMin;
    end
   
    % Consistency checks
    methods
        function obj = set.MinOrder(obj, value)
            import misc.isnatural;
            import var.arfit;
            if isempty(value) || numel(value)>1 || ~isnatural(value),
                throw(arfit.InvalidPropValue('MinOrder', ...
                    'Must be a natural scalar'));
            end
            obj.MinOrder = value;
        end
        
        function obj = set.MaxOrder(obj, value)
            import var.arfit;
            import misc.isnatural;
            if isempty(value) || numel(value) > 1 || ~isnatural(value),
                throw(arfit.InvalidPropValue('MaxOrder', ...
                    'Must be a natural scalar'));
            end
            obj.MaxOrder = value;
        end
        
         function obj = set.OrderCriterion(obj, value)
            import var.arfit;
            
            if isempty(value) || ~ischar(value),
                throw(arfit.InvalidPropValue('OrderCriterion', ...
                    'Must be a string'));
            end
            
            if ~ismember(lower(value), {'aic', 'sbc', 'fpe'}),
                throw(arfit.InvalidPropValue('OrderCriterion', ...
                    sprintf('Unknown criterion ''%s''', value)));
            end
            
            obj.OrderCriterion = lower(value);
            
         end
        
         
        function obj = set.ForceMin(obj, value)
            import var.arfit;
            if isempty(value) || numel(value) > 1 || ~islogical(value)
                throw(arfit.InvalidPropValue('ForceMin', ...
                    'Must be a logical scalar'));
            end  
            obj.ForceMin = value;
        end
        
    end
    
    % var.estimator interface
    methods
        obj  = learn_coeffs(obj, data, varargin);
    end
    
     
    
    % Constructor
    methods
        function obj = arfit(varargin)
            import misc.process_arguments;
            import var.globals;
            
            opt.MinOrder        = 1;
            opt.MaxOrder        = 30;
            opt.OrderCriterion  = 'sbc';
            opt.ForceMin        = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.MinOrder        = opt.MinOrder;
            obj.MaxOrder        = opt.MaxOrder;
            obj.OrderCriterion  = opt.OrderCriterion;
            obj.ForceMin        = opt.ForceMin;
            
        end
        
    end
    
    
    
end