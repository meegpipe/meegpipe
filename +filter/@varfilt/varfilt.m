classdef varfilt < filter.abstract_dfilt
    % VARFILT - Class for VAR filters
    
    
    properties
        VAR;
        ForceAR;
    end
    
    methods
        
        % Consistency checks
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
        
        function obj = set.ForceAR(obj, value)
            import filter.globals;
            if isempty(value),
                value = globals.evaluate.ForceAR;
            end
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('ForceAR', 'Must be a logical scalar'));
            end
            obj.ForceAR = value;
        end
        
        % filter.dfilt interface
        [y, obj] = filter(obj, x, varargin);
        
        % report.reportable interface
        [pName, pValue, pDescr]   = report_info(obj)
        
        % Constructor  
        function obj = varfilt(varargin)
            import misc.process_arguments;
            import filter.globals;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            opt.VAR             = var.arfit;
            opt.ForceAR         = globals.evaluate.ForceAR;
            
            opt.verboselabel    = '(filter.varfilt)';
            opt.verbose         = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.VAR         = opt.VAR;
            obj.ForceAR     = opt.ForceAR;
            
            obj = set_verbose(obj, opt.verbose);
            obj = set_verbose_label(obj, opt.verboselabel);
        end
        
    end
 
end