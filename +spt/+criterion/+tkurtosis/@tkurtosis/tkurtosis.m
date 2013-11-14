classdef tkurtosis < spt.criterion.rank.rank
    % TKURTOSIS - Ranks components according to their temporal kurtosis
    %
    %
    % See also: config
    
    % Documentation: class_tkurtosis.txt
    % Description: Selects components with extreme kurtosis values
    
    
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
        
        function obj = tkurtosis(varargin)                       
            
            obj = obj@spt.criterion.rank.rank(varargin{:});                 
            
        end
        
    end
    
end