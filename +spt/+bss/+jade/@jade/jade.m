classdef jade < spt.bss.abstract_bss
    
    % From spt.generic.generic
    methods
        [W, A, selection, obj] = learn_basis(obj, data, varargin);
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
        
        function obj = jade(varargin)
            
            obj = obj@spt.bss.abstract_bss(varargin{:});            
            
            if isempty(get_name(obj)),
                set_name(obj, 'jade');            
            end
            
        end
        
    end
    
    
end