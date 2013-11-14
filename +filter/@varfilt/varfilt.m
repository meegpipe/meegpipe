classdef varfilt < filter.abstract_dfilt
    % VARFILT - Class for VAR filters
    %
    % 
    % obj = varfilt;
    % obj = varfilt('key', value, ...)
    %
    % where
    % 
    % OBJ is a filter.varfilt object
    %
    %
    % ## Accepted key/value pairs:
    %
    % 'VAR'     : (var.var) A VAR model estimation algorithm. 
    %             Default: var.arfit
    %
    % 'AR'      : (logical) A logical scalar that determines whether each
    %             dimension should be modeled separately with a 1-D AR
    %             model or all dimensions should be modeled simultaneously
    %             using a Vector AR (VAR) model. 
    %             Default: false
    % 
    %
    % * Class varfilt inherits all properties from class
    %   filter.abstract_dfilt
    %
    %
    % ## Methods
    %
    % * Class varfilt implements the filter.dfilt interface. It also
    %   inherits all methods from class filter.abstract_dfilt
    %
    %
    % 
    %
    % See also: filter.abstract_dfilt, filter.dfilt
    
    
    properties
        VAR;
        AR;       
    end    
    
    methods
        
        function obj = varfilt(varargin) 
            import misc.process_arguments; 
            import filter.globals;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            opt.var             = var.arfit;
            opt.ar              = globals.evaluate.AR;
           
            opt.verboselabel    = '(filter.varfilt)';
            opt.verbose         = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.VAR         = opt.var;
            obj.AR          = opt.ar;            
            
            obj = set_verbose(obj, opt.verbose);
            obj = set_verbose_label(obj, opt.verboselabel);
        end       
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.VAR(obj, value)
            import filter.globals;
            import exceptions.*;
            
            if isempty(value),
                value = globals.evaluate.VAR;
            end
            if numel(value) ~= 1 || ~isa(value, 'var.algorithm'),
                throw(InvalidPropValue('VAR', ...
                    'Must be a var.algorithm object'));
            end
            obj.VAR = value;
        end
        
        function obj = set.AR(obj, value)
            import filter.globals;
            if isempty(value),
                value = globals.evaluate.AR;
            end
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('AR', 'Must be a logical scalar'));
            end
            obj.AR = value;
        end
        
    end
    
    
    methods
        % filter.dfilt interface
        [y, obj] = filter(obj, x, varargin);     
        
        % report.reportable interface
        [pName, pValue, pDescr]   = report_info(obj)
    end
    
    
    
   
end