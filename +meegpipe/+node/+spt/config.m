classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node spt
  
    properties        
        SPT;
        PCA;        
    end    
   
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
           
        end
        
    end
    
    
    
end