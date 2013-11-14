classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for tkurtosis criterion
    %
    % ## Usage synopsis:
    %
    %   import spt.criterion.rank.*;
    %   cfg = config('key', value, ...);
    %
    % ## Accepted key/value pairs:
    %
    %   MedFilerOrder : Natural scalar. Default: 5
    %       Order of the pre-processing median filter
    %
    %
    % See also: tkurtosis
    
    % Documentation: pkg_tkurtosis.txt
    % Description: Configuration for tkurtosis criterion
    
    
    properties
        
        MedFiltOrder = 5;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.MedFiltOrder(obj, value)
            
            import exceptions.*
            import misc.isnatural;
            
            if isempty(value),
                value = 5;
            end
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('MedFiltOrder', ...
                    'Must be a natural number'));
            end
            
            obj.MedFiltOrder = value;
                       
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end