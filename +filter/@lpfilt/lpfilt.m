classdef lpfilt < filter.abstract_dfilt
    % LPFILT - Low-pass digital filter
    %
    % obj = hpfilt(fc)
    %
    %
    % where
    %
    % OBJ is a filter.lpfilt object
    %
    % FC is the normalized cutoff of the low-pass filter
    %
    % See also: lpfilt, bpfilt, sbfilt
    
    properties (SetAccess=private)
        Order;
        TransitionBandWidth;   % Normalized!
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
        function obj = lpfilt(varargin)
            import misc.process_arguments;
            import filter.abstract_dfilt;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            if isnumeric(varargin{1}),
                varargin = [{'fc'}, varargin];
            end
        
            opt.fc = [];
            opt.transitionbandwidth = [];
            opt.maxorder = 30*1000;
            [~, opt] = process_arguments(opt, varargin);
            
            if isempty(opt.fc),
                error('The (normalized) cutoff frequency fc needs to be provided');
            end
            
            if isempty(opt.transitionbandwidth),
                opt.transitionbandwidth = max(1e-4, 0.01*(1-opt.fc)); 
            end

            order = firfilt.firwsord('hamming', 1, opt.transitionbandwidth);
            
            obj.Order = min(order, opt.maxorder);
            
            B = firfilt.firws(obj.Order, opt.fc, 'low', ...
                firfilt.windows('blackman', obj.Order + 1));
            obj.BAFilter = filter.ba(B, 1);
            
            obj.BAFilter = set_name(obj.BAFilter, get_name(obj));
            obj.BAFilter = set_verbose(obj.BAFilter, is_verbose(obj));
         
        end
        
    end
    
end