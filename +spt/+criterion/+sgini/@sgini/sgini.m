classdef sgini < spt.criterion.rank.rank
    % SGINI - Selects spatially sparse components
   
    % From criterion.trank
    methods
        
        idx = compute_rank(obj, sptObj, tSeries, sr, ev, rep, varargin);
        
    end    
    
    % Constructor
    methods
        
        function obj = sgini(varargin)                          
            
            obj = obj@spt.criterion.rank.rank(varargin{:});            
            
        end
        
    end        
 
    
end