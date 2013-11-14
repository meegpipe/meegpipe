classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for terp criterion
    %
    % See also: terp
    
    % Documentation: pkg_terp.txt
    % Description: Configuration for tkurtosis criterion
  
    properties
       
        EventSelector;
        LatencyRange;
        MaxShift;
        
    end
    
    
   
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end