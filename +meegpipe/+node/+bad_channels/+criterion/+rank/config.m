classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for rank criterion
    %
    % This class is not intended to be used directly. This class implements
    % consistency checks required for the construction of a valid 
    % meegpipe.node.bad_channels.criterion.rank.rank object. The 
    % configuration options listed below can be passed as key/value 
    % arguments during the construction of a rank criterion object.
    % 
    %
    %       Percentile : A percentage. Default: [2.5 97.5]
    %           Channels whose rank values fall below the Percentile(1) 
    %           percentile or that are larger than the Percentile(2)
    %           percentile will be selected.
    %
    %       MinCard : Natural scalar. Default: 0
    %           The minimum cardinality of the set of selected data
    %           channels (i.e. the minimum number of channels that will bem
    %           marked as bad).
    %
    %       MaxCard : Natural scalar. Default: Inf
    %           The maximum cardinality of the set of selected data
    %           channels, i.e. at most MaxCard channels will be marked as
    %           bad.
    %
    %       Min : A numeric scalar of function_handle. 
    %           Default: @(x) median(x)-20*mads(x);
    %           Minimum rank index value for a component to be selected. If
    %           a set handle then the actual threshold will be computed 
    %           from the vector of rank index values.
    %
    %       Max : A numeric scalar or function_handle. 
    %           Default: @(x) median(x)+20*mads(x);
    %           Maximum rank index value for a component to be selected.
    %
    %
    % See also: rank
    
    properties
 
        MinCard     = 0;
        MaxCard     = @(dim) ceil(0.2*dim);
        Percentile  = [2 98];  
        Min         = @(x) median(x)-10*mad(x);
        Max         = @(x) median(x)+10*mad(x);
      
    end
    
     % Consistency checks
    methods    
        
        function obj = set.Percentile(obj, value)
            
            import exceptions.*;
            
            if isempty(value), 
                obj.Percentile = [];
                return;
            end
            
            if numel(value) ~= 2 || ~isnumeric(value) || any(value < 0) || ...
                    any(value > 100)
                throw(InvalidPropValue('Percentile', ...
                    'Must be a percentile'));
            end
            
            obj.Percentile = value;
            
        end
        
        function obj = set.MaxCard(obj, value)
           
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                obj.MaxCard = @(dim) ceil(0.2*dim);
                return; 
            end
            
            if numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('MaxCard', ...
                    'Must be a natural scalar or function_handle'));
            end
            
            obj.MaxCard = value;           
            
        end
        
        function obj = set.MinCard(obj, value)
           
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                obj.MinCard = 0;
                return; 
            end
            
            if numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('MinCard', ...
                    'Must be a natural scalar of function_handle'));
            end
            
            obj.MinCard = value;           
            
        end
         
    end
    
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
          
            
        end
        
    end
    
    
    
end