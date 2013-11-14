classdef var < spt.criterion.rank.rank
    
     methods
       
        idx = compute_rank(obj, sptObj, tSeries, sr, ev, rep, varargin);
        
    end    
 
     % Constructor
    methods
        
        function obj = var(varargin)
            
            obj = obj@spt.criterion.rank.rank(varargin{:});
            
        end
        
    end
 
end