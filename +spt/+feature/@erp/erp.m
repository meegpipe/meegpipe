classdef erp < spt.feature.feature & goo.verbose
    % ERP - Event Related Potential stability across trials
    
    properties
        EventSelector = []; % Select ERP events
        Offset        = []; % Taken from events if empty (in seconds)
        Duration      = []; % Taken from events if empty (in seconds)
    end
    
    
    methods
        
        % spt.feature.feature interface
        featVal = extract_feature(~, sptObj, varargin)
        
        % Constructor
        function obj = erp(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.EventSelector = []; 
            opt.Offset        = []; 
            opt.Duration      = []; 
            obj = set_properties(obj, opt, varargin); 
        end
        
    end
    
    
    
end