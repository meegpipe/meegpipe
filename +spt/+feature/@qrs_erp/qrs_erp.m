classdef qrs_erp < spt.feature.feature & goo.verbose
    % QRS_ERP - Stabibility of QRS-locked ERP
    
    properties
        
        % For building the ERP
        Duration   = 0.4;  % in seconds
        Offset     = 0.08; % in seconds
        
    end
    
    
    methods
        
        % spt.feature.feature interface
        featVal = extract_feature(obj, ~, tSeries, varargin);
        
        % Constructor
        function obj = qrs_erp(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            % For building the ERP
            opt.Duration   = 0.4;  % in seconds
            opt.Offset     = 0.08; % in seconds
            obj = set_properties(obj, opt, varargin);
        end
        
    end
    
    
    
end