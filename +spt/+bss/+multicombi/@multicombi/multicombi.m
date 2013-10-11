classdef multicombi < spt.bss.abstract_bss

    
    % Documentation: class_multicombi.txt
    % Description: Class definition
  
     properties (SetAccess = private, GetAccess = private)
        
        RandState_;
        Init_;
        
    end
       
    % From spt.generic.generic
    methods
        [W, A, selection, obj] = learn_basis(obj, data, varargin);
    end    
      
    % Constructor and invariant checks
    methods
        
        function obj = multicombi(varargin)
            
            import misc.struct2cell;
            
            obj = obj@spt.bss.abstract_bss(varargin{:});
            
            obj = set_name(obj, 'multicombi');
            
        end        
        
    end
    
  
    
end