classdef estimator < var.abstract_var & misc.setget & misc.verbose
    % ESTIMATOR - Class for VAR estimation algorithms
    %
    % Documentation to be done...
    %
    %
    % See also: var.abstract_var, var.var, var
    
    % Description: Common ancestor for VAR estimation algorithms
    % Documentation: class_var_estimator.txt
    
    properties (SetAccess = protected, GetAccess = protected)
        DataMean;
        Coeffs;
        Residuals;
        ResCov;
        NoiseCov;
        ACov;            
    end
    
    % Exceptions
    methods (Static, Access =private)
        function obj = InvalidPropValue(prop, msg)
           if nargin < 1 || isempty(prop), prop = '??'; end
           if nargin < 2 || isempty(msg), msg = ''; end
           msg = sprintf('Invalid ''%s'': %s', prop, msg);
           obj = MException('var:estimator:InvalidPropValue', msg);
        end
        
        function obj = InvalidArgument(name)
            if nargin < 1, name = []; end
            
            if ~isempty(name),
                obj = MException(...
                    'var:estimator:InvalidArgument', ...
                    'Argument ''%s'' is invalid', name);
            else
                obj = MException(...
                    'var:estimator:InvalidArgument', ...
                    'Invalid argument(s)');
            end
        end
        
    end
    
    
    % Public interface ....................................................
    
    properties
        Algorithm;
        Univariate;
        PCA;
        MaxCond;
        EventSpecs;     % This two properties are currently ignored
        EventLatRange;
    end
    
    % var.var interface
    methods
       % modifiers           
        obj         = set_coeffs(obj, A);
        obj         = set_innovations(obj, inn);
        obj         = set_icov(obj, C);
        obj         = set_ncov(obj, C);
        
        % accessors        
        c           = coeffs(obj);
        C           = ncov(obj);
        obs         = observations(obj, varargin);
        inn         = innovations(obj, varargin);
        [C, Cminus] = acov(obj, lag, idx, varargin);
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
            
            % Public properties
            opt.Algorithm       = var.arfit;
            opt.Univariate      = false;
            opt.PCA             = [];
            opt.MaxCond         = 1e10;
            opt.EventSpecs      = [];
            opt.EventLatRange   = [];
            
            
            [~, opt] = process_arguments(opt, varargin);
            
            fNames = fieldnames(opt);
            for argItr = 1:numel(fNames)
                obj.(fNames{argItr}) = opt.(fNames{argItr});
            end
            
            
        end
    end
    
    
    
end