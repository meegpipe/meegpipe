classdef config < spt.generic.config
    % CONFIG - Configuration for class amica
    %
    %
    % See also: spt, abstract_spt
   
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        NbMixtures  = 3;         
        MaxIter     = 500;  
        UpdateRho   = true; 
        MinLL       = 1e-8;  
        IterWin     = 50;
        DoNewton    = true;          
      
    end
    
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.generic.config(varargin{:});
            
        end
        
    end
    
    
    
end