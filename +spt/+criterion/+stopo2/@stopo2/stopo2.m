classdef stopo2 < spt.criterion.rank.rank
    
    
    
    methods
        idx = compute_rank(obj, tseries, varargin);
    end
    
    % Static constructors
    methods (Static)
       obj = eog(varargin); 
    end
  
    % Constructor
    methods
        function obj = stopo2(varargin)          
            
            obj = obj@spt.criterion.rank.rank(varargin{:});            
           
        end
    end
    
    
end