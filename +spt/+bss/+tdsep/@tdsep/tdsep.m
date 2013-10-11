classdef tdsep < spt.bss.abstract_bss
    
    
    % From spt.generic.generic
    methods
        [W, A, selection, obj] = learn_basis(obj, data, ev, varargin);
    end
    
    
    % Constructor
    methods
        
        function obj = tdsep(varargin)
            
            
            obj = obj@spt.bss.abstract_bss(varargin{:});
            
            set_name(obj, 'tdsep');
            
        end
        
    end
    
    
end