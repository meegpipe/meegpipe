classdef abstract_dfilt < ...
        filter.dfilt             & ...
        goo.verbose              & ...
        goo.reportable           & ...
        goo.abstract_setget      & ...
        goo.printable            & ...
        goo.abstract_named_object
    % ABSTRACT_DFILT - Common ancestor to digital filter classes
    
    methods (Static, Access = protected)
        
        [y, wp, ws, rp, rs] = filt_ord(designmethod, wp, ws, rp, rs, type)
        
    end

    methods
        
        % Conversion to a MATLAB dfilt.?? object
        function H =  mdfilt(obj) %#ok<STOUT>
            error('Class %s does not implement method mdfilt', class(obj));
        end
        function obj = set_persistent(obj, ~)
            % arg2 is a boolean value
            error('Class %s does not implement method set_persistent', ...
                class(obj));
        end
        
    end
    
    methods
        
        y = filtfilt(obj, x, varargin);
        
    end

    % report.printable interface
    methods
        count = fprintf(fid, obj, varargin);
    end
    
    % report.reportable interface
    methods
        
        function str = whatfor(~)
            str = '';
        end
        
    end
    
    % Virtual constructor
    methods
        function obj = abstract_dfilt(varargin)
            
            obj = obj@goo.abstract_named_object(varargin{:});
            
            % Default verbose label
            obj = set_verbose_label(obj, ...
                @(x, meth) sprintf('(%s:%s) ', class(x), meth));
        end
        
    end
    
    
end