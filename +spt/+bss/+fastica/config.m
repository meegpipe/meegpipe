classdef config < spt.generic.config
    % CONFIG - Configuration for class fastica
    %
    %
    % See also: spt, abstract_spt

    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Approach        = 'symm';
        Nonlinearity    = 'pow3';
        InitGuess       =  @(data) eye(size(data,1));
      
    end
    
    % Consistency checks
    methods
        
        function obj = set.Approach(obj, value)
            
            import misc.join;
            import exceptions.*
            
            validApproaches = {'symm', 'defl'};
            
            if ~ischar(value) || ~ismember(value, validApproaches),
                throw(InvalidPropValue('Approach', ...
                    sprintf('Must be any of: %s', ...
                    join(', ', validApproaches))));
            end
            
            obj.Approach = value;
            
        end
        
          
        function obj = set.Nonlinearity(obj, value)
            
            import misc.join;
            import exceptions.*
            
            validNonlins = {'pow3', 'tanh', 'gauss', 'skew'};
            
            if ~ischar(value) || ~ismember(value, validNonlins),
                 throw(InvalidPropValue('Approach', ...
                    sprintf('Must be any of: %s', ...
                    join(', ', validNonlins))));
            end
            
            obj.Nonlinearity = value;
            
        end
        
       
    
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.generic.config(varargin{:});
            
        end
        
    end
    
    
    
end