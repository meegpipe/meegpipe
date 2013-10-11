classdef efica < spt.bss.abstract_bss
    
    
    % Public interface ....................................................
    
    % From spt.generic.generic
    methods
        [W, A, selection, obj] = learn_basis(obj, data, varargin);
    end    
    
    % Constructor
    methods
        function obj = efica(varargin)
            obj = obj@spt.bss.abstract_bss(varargin{:});
        end
        
    end
    
    
end