classdef tpca < ...
        filter.dfilt                & ...   
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    % TPCA - Temporal PCA filter
    %
    % ## Usage synopsis:
    %
    % obj = bpfilt('key', value, ...)
    % y = tpca(obj, x)
    %
    % Where
    %
    % OBJ is a tpca object
    %
    % X is the input to the filter (a KxM numeric matrix).
    %
    % Y is the filtered output (a KxM numeric matrix).
    %
    % 
    % ## Acepted key/value pairs:
    %
    %       Order : A natural scalar. Default: 100
    %           The number of time lags to use to build the delay-embedded
    %           data matrix
    %
    %       PCA : A spt.pca.pca object. Default: spt.pca('MaxDimOut', 5)
    %           The PCA to be applied to the delay-embedded data matrix.
    %
    %
    % See also: filter

    
    properties
       
        Order = 100;
        PCA   = spt.pca.pca('MaxDimOut', 5);
        
    end
    
    % filter.dfilt interface
    methods
        [y, obj] = filter(obj, x, varargin);
        
        function [y, obj] = filtfilt(obj, x, varargin)
            
             [y, obj] = filter(obj, x, varargin{:});
            
        end
    end
    
    % Constructor
    methods
        
        function obj = tpca(varargin)
           
            import misc.process_arguments;
            
            opt.Order   = 100;
            opt.PCA     = spt.pca.pca('MaxDimOut', 5);
            opt.Name    = 'tpca';
            opt.Verbose = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Order = opt.Order;
            obj.PCA   = opt.PCA;
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
    
    
    
    
end