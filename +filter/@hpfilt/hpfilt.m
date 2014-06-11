classdef hpfilt < filter.abstract_dfilt
    % HPFILT - High-pass digital filter
    %
    % obj = hpfilt(fc)
    %
    %
    % where
    %
    % OBJ is a filter.lpfilt object
    %
    % FC is the normalized cutoff of the high-pass filter
    %
    % See also: lpfilt, bpfilt, sbfilt
    
    properties (SetAccess=private)
        Order;
    end
    
    properties (SetAccess = private)
        BAFilter;
    end
    
    methods
        
        function [y, obj] = filter(obj, varargin)
            [y, obj] = filter(obj.BAFilter, varargin{:});
        end
        
        function y = filtfilt(obj, varargin)
            y = filtfilt(obj.BAFilter, varargin{:});
        end
        
        function H = mdfilt(obj)
            H = mdfilt(obj.BAFilter);
        end
        
        % Constructor
        function obj = hpfilt(varargin)
            import misc.process_arguments;
            import filter.abstract_dfilt;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            if isnumeric(varargin{1}),
                varargin = [{'fc'}, varargin];
            end
        
            opt.fc = [];
            [~, opt] = process_arguments(opt, varargin);
            
            filterOrder = 6;
            [B, A] = butter(filterOrder, opt.fc, 'high');
            
            while any(abs(roots(A)) >= 1) && filterOrder > 2,
                filterOrder = filterOrder - 1;
                [B, A] = butter(filterOrder, opt.fc, 'high');
            end
            if any(abs(roots(A)) >= 1)
                error(['Filter coefficients have poles on or outside ' ...
                    'the unit circle and will not be stable. Try a higher cutoff ' ...
                    'frequency or a different type/order of filter.']);
            end
            obj.Order = filterOrder;
            
            obj.BAFilter = filter.ba(B, A);
            
            obj.BAFilter = set_name(obj.BAFilter, get_name(obj));
            obj.BAFilter = set_verbose(obj.BAFilter, is_verbose(obj));
         
        end
        
    end
    
end