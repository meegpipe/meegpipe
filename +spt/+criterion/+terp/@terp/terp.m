classdef terp < spt.criterion.rank.rank
    % Criterion that selects ERP components in the time domain
    
    methods
        
        idx = compute_rank(obj, sptObj, tSeries, varargin);
        
    end
    
    % Constructor
    methods
        
        function obj = terp(varargin)
            
            obj = obj@spt.criterion.rank.rank(varargin{:});
            
        end
        
    end
    
    
end