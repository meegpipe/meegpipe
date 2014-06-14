classdef hpfilt_ellip < filter.abstract_dfilt
    % HPFILT_ELLIP - High-pass digital filter using elliptic filter design
    %
    % obj = hpfilt_ellip(fc)
    %
    %
    % where
    %
    % OBJ is a filter.hpfilt_ellip object
    %
    % FC is the normalized cutoff of the high-pass filter
    %
    % See also: filter.hpfilt
    
    properties (SetAccess=private)
        Fc;
        Order;
        Delay;
        Specs;
        H;
    end
    
    methods (Static)
       [order, fs, rp, rs] = find_filter_order(fc, fc, rp, rs); 
    end
    
    methods
        
        % filter.dfilt interface
        [y, obj] = filter(obj, varargin)
        y = filtfilt(obj, varargin)
        
        % from abstract_dfilt
        function H = mdfilt(obj)
            H = obj.H;
        end
        
        % Constructor
        function obj = hpfilt_ellip(varargin)
            import misc.process_arguments;
            import filter.abstract_dfilt;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            if isnumeric(varargin{1}),
                varargin = [{'fc'}, varargin];
            end
            
            opt.fc = [];
            [~, opt] = process_arguments(opt, varargin);
            
            [obj.Order, fst, rp, rs] = filter.hpfilt_ellip.find_filter_order(...
                1.05*opt.fc, 0.9*opt.fc, 0.5, 45);
            obj.Specs = fdesign.highpass('Fst,Fp,Ast,Ap', fst, opt.fc, rs, rp);
            obj.H = design(obj.Specs, 'ellip');
            obj.Fc = opt.fc;
            [Gd,W] = grpdelay(obj.H, 256);
            obj.Delay = round(mean(Gd(W<opt.fc*pi)));
            
        end
        
    end
    
end