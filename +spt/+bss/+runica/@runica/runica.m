classdef runica < spt.bss.abstract_bss
    
    
    %% PUBLIC INTERFACE ...................................................
    
    % From spt.generic.generic
    methods
        
        [W, A, selection, obj] = learn_basis(obj, data, varargin);
        
    end
    
    
    % Constructor
    methods
        function obj = runica(varargin)            
            
            obj = obj@spt.bss.abstract_bss(varargin{:});
            
            obj = set_name(obj, 'runica');
            
        end
    end
    
end