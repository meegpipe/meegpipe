classdef mrank < spt.criterion.rank.rank
    % Multiple rank criteria combined
    % The components that rank highest in each criterion will be selected

    % Constructor
    methods
        
        function obj = mrank(varargin)                        
            
            obj = obj@spt.criterion.rank.rank(varargin{:});                      
        
        end
        
    end
    
 
    methods
        
        idx = compute_rank(obj, tSeries, varargin)
        
    end
    
       % Static factories
    methods (Static)
        obj = eog(varargin); 
    end
    
    
end