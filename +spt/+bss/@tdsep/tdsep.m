classdef tdsep < spt.abstract_spt
    % TDSEP - TDSEP algorithm for blind source separation
    
    
    properties        
        Lag = 1;
    end
    
    methods
        obj = learn_basis(obj, data, ev, varargin);
    end
    
    
    % Constructor
    methods
        
        function obj = tdsep(varargin)
            
            
            obj = obj@spt.abstract_spt(varargin{:});
            
            opt.Lag = 1;
            obj = set_properties(obj, opt, varargin{:});
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'tdsep');
            end
            
        end
        
    end
    
    
end