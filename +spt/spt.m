classdef spt
    % SPT - Interface for spatial transforms
    
    methods (Abstract)
        
        % Mutable abstract methods
        
        obj          = learn(obj, data, ev, sr);
        
        obj          = match_sources(source, target, varargin);
        
        obj          = select_component(obj, idx, backup);
        
        obj          = select_dim(obj, idx, backup);
        
        obj          = invert_component_selection(obj, backup);
        
        obj          = invert_dim_selection(obj, backup);
        
        obj          = clear_selection(obj);
        
        obj          = restore_selection(obj);
        
        obj          = cascade(varargin);        
        
       
        % Inmutable abstract methods
        
        W           = projmat(obj);
        
        A           = bprojmat(obj);
        
        [data, I]   = proj(obj, data);
        
        [data, I]   = bproj(obj, data);
        
        I           = component_selection(obj);    
        
        I           = dim_selection(obj);
        
        val         = nb_dim(obj);
        
        val         = nb_component(obj);
        
        
    end
    
    
end