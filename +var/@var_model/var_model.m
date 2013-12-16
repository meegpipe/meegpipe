classdef var_model < goo.verbose
    % VAR_MODEL - A VAR model class

    
    properties (SetAccess = private, GetAccess = private)
        DataMean;
        Coeffs;
        Innovations;
        InnCov;
        NoiseCov;
        ACov;
    end
    
    % Interface
    methods 
        % simple property modifiers           
        obj         = set_coeffs(obj, A);
        obj         = set_mean(obj, A);
        obj         = set_innovations(obj, inn);
        obj         = set_innovations_cov(obj, C);
        obj         = set_noise(obj, noise);        
        obj         = set_noise_cov(obj, C);
        
        % more involved modifiers
        obj         = linmap(obj, A);
        obj         = disconnect(obj);  
        
        % simple property accessors
        c           = get_coeffs(obj);
        inn         = get_innovations(obj, varargin);
        C           = get_innovations_cov(obj);
        noise       = get_noise(obj);
        C           = get_noise_cov(obj);
        obs         = get_observations(obj, varargin);        
        
        % more involved accessors
        M           = adjmat(obj, varargin);
        M           = dirmat(obj, varargin);
        M           = distmat(obj, varargin);
        dim         = dim(obj);
        ord         = order(obj);
        C           = icov(obj);
        
        pteVal      = pte(obj,      Gamma, Phi, Theta, lag, varargin);
        pmiVal      = pmi(obj,      Gamma, Phi, Theta, lag, varargin);
        cmiVal      = cmi(obj,      Gamma, Phi, Theta, lag, varargin);
        gcVal       = gc(obj,       Gamma, Phi, Theta, lag, varargin);
        diVal       = ptedir(obj,   Gamma, Phi, Theta, lag, varargin);
        diVal       = pmidir(obj,   Gamma, Phi, Theta, lag, varargin);
        diVal       = cmidir(obj,   Gamma, Phi, Theta, lag, varargin);
        diVal       = gcdir(obj,    Gamma, Phi, Theta, lag, varargin);
        
        [C, Cminus] = analytical_cov(obj, lag, idx, varargin);
        
    end

end