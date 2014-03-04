classdef tkurtosis < spt.feature.feature & goo.verbose
    % TKURTOSIS - Temporal kurtosis
    
    properties
       MedFiltOrder = 5;
       Nonlinearity = @(x) x.^2;
    end
    
    methods
        
        % spt.feature.feature interface
        idx = extract_feature(obj, sptObj, tSeries, raw, varargin)     
        
        % Constructor
        
        function obj = tkurtosis(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.MedFiltOrder  = 5;
            opt.Nonlinearity  = @(x) x.^2;
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
end