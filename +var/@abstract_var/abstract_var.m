classdef abstract_var < var.var & misc.verbose
    % ABSTRACT_VAR - Common functionality for VAR models
    %
    % This class implements common methods among var.var classes, which can
    % be implemented only in terms of the var.var interface definition
    %
    %
    %
    % See also: var.var, var
    
    % Documentation: class_var_abstract_var.txt
    % Documentation: Common functionality for VAR models
    
    % Exceptions
    methods (Static, Access =private)
        function obj = InvalidPropValue(prop, msg)
            if nargin < 1 || isempty(prop), prop = '??'; end
            if nargin < 2 || isempty(msg), msg = ''; end
            msg = sprintf('Invalid ''%s'': %s', prop, msg);
            obj = MException('var:abstract_var:InvalidPropValue', msg);
        end
    end
    
    
    % Public interface ....................................................    
    methods
        % Mutators
        obj         = linmap(obj, A);
        obj         = disconnect(obj);        
        
        % Accessors
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
    end    
    
    
    % new methods defined by this class
    methods (Access = protected)
        [C, Cminus] = compute_acov(obj, lag, idx, varargin); 
    end
    
    
end