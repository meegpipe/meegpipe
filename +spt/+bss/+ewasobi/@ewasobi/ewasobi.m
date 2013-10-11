classdef ewasobi < spt.bss.abstract_bss
    
  
    % PUBLIC INTERFACE ....................................................
 
    % From spt.generic.generic
    methods
        [W, A, obj] = learn_basis(obj, data, varargin);
    end    
 
    % Constructor
    methods
        function obj = ewasobi(varargin)             
       
            obj = obj@spt.bss.abstract_bss(varargin{:});             
        
        end
        
    end            
   
    
end