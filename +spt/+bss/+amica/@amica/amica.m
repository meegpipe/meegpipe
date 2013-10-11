classdef amica < spt.bss.abstract_bss
    
    
    % PUBLIC INTERFACE ....................................................
    
    % From spt.generic.generic
    methods
        [W, A, selection, obj] = learn_basis(obj, data, varargin);
    end
    
    % Constructor
    methods
        function obj = amica(varargin)
            
            obj = obj@spt.bss.abstract_bss(varargin{:});
            
            obj = set_name(obj, 'amica');            
            
        end
    end
    
end