classdef method_config

    
    
    properties (SetAccess = private, GetAccess = private)
        
        Config = mjava.hash;
        
    end
    
    %% PUBLIC INTERFACE ...................................................
    
    methods
        
        obj = set_method_config(obj, varargin);
        
        value = get_method_config(obj, varargin);
        
    end
    
    
    % Constructor
    methods
        function obj = method_config(varargin)
            
            if nargin < 1, return; end
            
            if nargin == 1 && isa(varargin{1}, 'goo.method_config'),
                % Copy constructor
                obj = varargin{1};
                return;
            end
            
            obj = set_method_config(obj, varargin{:});
            
        end
        
    end
    
end