classdef fastica < spt.bss.abstract_bss
    
    
    
    %% PUBLIC INTERFACE ....................................................
    
    % From spt.generic.generic
    methods
        [W, A, selection, obj] = learn_basis(obj, data, varargin);
        
        function init = get_init(obj, data)
            
            import misc.isnatural;
            
            init = get_init@spt.bss.abstract_bss(obj, data);
            
            if isempty(init)
                
                init = get_config(obj, 'InitGuess');
                
                if isa(init, 'function_handle'),
                    init = init(data);
                elseif numel(data)==1 && isnatural(data),
                    % data is the dimensionality of the input data
                    init = rand(data);
                elseif isempty(init) || all(isnan(init(:))),
                    init = randi(10*size(data,1)^2, size(data,1));
                end
                
                
            end
        end
    end
    
    % Constructor and invariant checks
    methods
        function obj = fastica(varargin)
            
            obj = obj@spt.bss.abstract_bss(varargin{:});            
            
            obj = set_name(obj, 'fastica');
            
        end
        
        
    end
    
    
    
end
