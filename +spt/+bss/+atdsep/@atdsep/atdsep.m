classdef atdsep < spt.bss.abstract_bss
    
    
    % From spt.generic.generic
    methods
        [W, A, selection, obj] = learn_basis(obj, data, ev, varargin);
    end
    
    % bss.bss interface
    methods
        
        function obj = set_seed(obj, ~)
            
            % do thing
            
        end
        
        function seed = get_seed(~)
            
            seed = [];
            
        end
        
        function init = get_init(~, ~)
            
            init = [];
            
        end
        
        function obj = set_init(obj,  ~)
            
            % do nothing
            
        end
        
        function obj = clear_state(obj)
            
            % do nothing
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = atdsep(varargin)            
            
            obj = obj@spt.bss.abstract_bss(varargin{:});
            
            set_name(obj, 'atdsep');
            
        end
        
    end
    
    
end