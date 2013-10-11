classdef spt
    % SPT - Interface for spatial transformations
    %
    % See also: abstract_spt, spt
    
    % Documentation: ifc_spt.txt
    % Description: Interface for spatial transformations
    
    
    methods (Abstract)
        
        %% Mutable abstract methods
        
        obj          = learn(obj, data, ev, sr);
        
        obj          = learn_dualreg(obj, data);
        
        obj          = match_sources(obj, A, varargin);
        
        obj          = select(obj, idx);
        
        obj          = deselect(obj, idx);
        
        obj          = clear_selection(obj);
        
        obj          = set_basis(obj, W, A);
        
        obj          = cascade(objArray);
        
        obj          = lmap(obj, W);
        
        obj          = rmap(obj, W);
        
        %% Inmutable (const) abstract methods
    
        W            = projmat(obj);
        
        A            = bprojmat(obj);
        
        [data, idx]  = proj(obj, data);
        
        [data, idx]  = bproj(obj, data);
        
        idx          = selection(obj);
   
    end
    
    
    
end