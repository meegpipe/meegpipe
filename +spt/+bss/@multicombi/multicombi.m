classdef multicombi < spt.abstract_spt
% MULTICOMBI - Multicombi algorithm for BSS

    properties
       AROrder =  10;
    end

    methods
        obj = learn_basis(obj, data, varargin);
    end    
      
    methods
        
        function obj = multicombi(varargin)
          
            obj = obj@spt.abstract_spt(varargin{:});
            
            opt.AROrder = 10;            
            obj = set_properties(obj, opt, varargin{:});
            
            if isempty(get_name(obj))
                obj = set_name(obj, 'multicombi');
            end
            
        end        
        
    end
    
  
    
end