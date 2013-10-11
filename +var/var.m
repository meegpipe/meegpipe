classdef var
    % VAR - Interface for classes that implement VAR models
    %
    %
    % ## Most relevant methods:
    %
    % To be done...
    %
    % See also: var, var.abstract_var
    
    % Description: Interface for VAR models
    % Documentation: ifc_var_var.txt
    
  
    % Interface
    methods (Abstract)
        % modifiers           
        obj         = set_coeffs(obj, A);
        obj         = set_inn(obj, inn);
        obj         = set_icov(obj, C);
        obj         = set_noise(obj, noise);        
        obj         = set_ncov(obj, C);
        
        % accessors
        c           = get_coeffs(obj);
        inn         = get_inn(obj, varargin);
        C           = get_icov(obj);
        noise       = get_noise(obj);
        C           = get_ncov(obj);
        obs         = get_obs(obj, varargin);        
    end

end