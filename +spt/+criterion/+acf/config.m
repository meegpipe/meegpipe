classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for acf criterion
    %
    %
    % See also: acf
    
    % Documentation: pkg_acf.txt
    % Description: Configuration for acf criterion
    
    properties
        
        Period         = 1.1;     % In seconds
        PeriodMargin   = 0;
        NbPeriods      = 5;
        Delta          = 0.1;
        
    end
    
    % Consistency checks (to be done)
    methods
        
        function obj = set.Period(obj, value)
            
            obj.Period = value;
            
        end
        
        function obj = set.PeriodMargin(obj, value)
            
            obj.PeriodMargin = value;
        end        
        
    end
    
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end