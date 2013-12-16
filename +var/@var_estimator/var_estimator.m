classdef var_estimator < goo.setget & goo.verbose
    % VAR_ESTIMATOR - Class for VAR estimation algorithms
    
   
    
    properties
        Univariate;
        PCA;
        MaxCond;
    end
    
    % var.var interface
    methods
        
        % accessors
        obs         = observations(obj, varargin);
        inn         = innovations(obj, varargin);
    end
    
    % Children classes must implement this
    methods (Abstract)
        A = learn_coeffs(obj, data);
    end
    
    % Public methods (defined and implemented here)
    methods
        % mutators
        obj     = learn(obj, data, varargin);
        obj     = pack(obj);
        
        % accessors
        data    = residuals(obj, data);
    end
    
    % Contructor
    methods
        function obj = estimator(varargin)
            
            import misc.process_arguments;
            import var.estimator;
            import misc.set_properties;
            
            % Public properties
            opt.Algorithm       = var.arfit;
            opt.Univariate      = false;
            opt.PCA             = [];
            opt.MaxCond         = 1e10;
            opt.EventSpecs      = [];
            opt.EventLatRange   = [];

            [~, opt] = process_arguments(opt, varargin);
            
            obj = set_properties(obj, opt);
            
        end
    end
    
    
    
end