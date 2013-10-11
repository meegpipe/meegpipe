classdef config < spt.generic.config
    % CONFIG - Configuration for class tdsep
    %
    %
    % See also: spt, spt.bss
      
    %% PUBLIC INTERFACE ...................................................    
    properties
        
        Lag = 1;
        EventClass;
      
    end

    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.generic.config(varargin{:});
            
        end
        
    end
    
    
    
end