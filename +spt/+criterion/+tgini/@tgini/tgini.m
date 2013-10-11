classdef tgini < spt.criterion.rank.rank
    % TGINI - Selects components with extreme Gini index [1] values 
    %
    % See also: config
    
    % Public interface ....................................................
    
    % From criterion.trank
    methods
        idx = compute_rank(obj, tseries, varargin);
    end
    
    % Static constructors
    methods (Static)
       obj = eog(varargin); 
    end
  
    % Constructor
    methods
        function obj = tgini(varargin)          
           
            obj = obj@spt.criterion.rank.rank(varargin{:});
            
        end
    end
    
end