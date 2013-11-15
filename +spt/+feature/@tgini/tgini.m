classdef tgini < spt.feature.feature & goo.verbose
    % TGINI - Gini index
 
    methods
        
        % spt.feature.feature interface
        function featVal = extract_feature(~, ~, tSeries, varargin)
            
            import misc.gini_idx;
           
            featVal = nan(1, size(tSeries,1));
            for i = 1:size(tSeries,1)
               featVal(i) = gini_idx(tSeries(i,:)');
            end
  
        end
      
    end
    
    
    
end