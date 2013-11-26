classdef sgini < spt.feature.feature & goo.verbose
    % SGINI - Spatial gini index
    
    methods
        
        % spt.feature.feature interface
        function featVal = extract_feature(~, sptObj, varargin)
            
            import misc.gini_idx;
            
            M = bprojmat(sptObj);
            
            featVal = gini_idx(M);
            
            featVal = featVal(:);
            
        end
        
    end
    
    
    
end