classdef lasip < ...
        filter.dfilt                & ...   
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    
    properties
        
        Order;
        Gamma;
        Scales;
        WindowType;
        WeightsMedian;
        InterpMethod;
        GetNoise;
        Decimation;
        ExpandBoundary;
        
        % VarTh can be used to deactivate filter operation when the filter
        % does not produce any significant changes on the input data. This
        % parameter is the ratio of var(output)/var(input) in percentage
        % that should be exceeded for the filter output not to be discarded
        % (for being negligible).
        VarTh = 0;  
       
    end
    
    % Consistency checks to be done later
    
    % filter.interface
    methods
        [y, obj] = filter(obj, x, varargin);
        
        function [y, obj] = filtfilt(obj, varargin)
           
            [y, obj] = filter(obj, varargin{:});
            
        end
    end    
    
    % Static constructors
    methods (Static)
       
        obj = eog(varargin);
        
    end
    
    % Constructor
    methods
        function obj = lasip(varargin)
            import misc.process_arguments;
            
            opt.Order            = 2;
            opt.Gamma            = 1:0.2:4;
            opt.Scales           = ceil([3 1.45.^(4:16)]);
            opt.WindowType       = ...
                {'Gaussian', 'GaussianLeft', 'GaussianRight'};
            opt.WeightsMedian    = [1 1 1 3 1 1 1];
            opt.InterpMethod     = 'spline';
            opt.GetNoise         = false;
            opt.Decimation       = 1;
            opt.ExpandBoundary   = 2;
            opt.Verbose          = false;
            opt.Name             = 'lasip';
            opt.VarTh            = 0;
            [~, opt] = process_arguments(opt, varargin);
            
            fNames = setdiff(fieldnames(opt), {'Verbose', 'Name'});
            for i = 1:numel(fNames)
                obj.(fNames{i}) = opt.(fNames{i});
            end
            
            obj = set_verbose(obj, opt.Verbose);
            obj = set_name(obj, opt.Name);
            
        end
        
    end
    
    
end