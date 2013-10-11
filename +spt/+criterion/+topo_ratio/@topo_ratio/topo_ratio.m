classdef topo_ratio < spt.criterion.rank.rank
    % TOPO_RATIO - Selects components using a topographical ratio
  
    
    
    methods
       
        idx = compute_rank(obj, sptObj, tSeries, sr, ev, rep, varargin);
        
    end    
 
     % Constructor
    methods
        
        function obj = topo_ratio(varargin)
            
            obj = obj@spt.criterion.rank.rank(varargin{:});
            
        end
        
    end
    
    
    
end