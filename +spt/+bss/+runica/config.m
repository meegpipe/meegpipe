classdef config < spt.generic.config
    % CONFIG - Configuration for class runica
    %
    %
    % See also: spt, spt.bss

    %% PUBLIC INTERFACE ...................................................   
    properties
        
        Extended = spt.bss.runica.globals.get.Extended;
       
    end
    
    % Consistency checks
    methods
        
        function obj = set.Extended(obj, value)
            
            import misc.join;
            import exceptions.*
            
          
            if numel(value) ~= 1 || ~islogical(value)
                throw(InvalidPropValue('Extended', ...
                    'Must be a logical scalar'));
            end
            
            obj.Extended = value;
            
        end
        
       
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.generic.config(varargin{:});
            
        end
        
    end
    
    
    
end