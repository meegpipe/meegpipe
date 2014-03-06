classdef topo_frontal < spt.feature.feature & goo.verbose
    
    properties
       R0 = 0.65; 
       R1 = 1;
    end
    
    methods
        
        [idx, featName] = extract_feature(obj, sptObj, tSeries, raw, varargin);

        % Constructor
        function obj = topo_frontal(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.R0 = 0.65;
            opt.R1 = 1;      
           
            obj = set_properties(obj, opt, varargin);
            
        end
    end
    
    
end