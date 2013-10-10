classdef config < goo.abstract_setget_handle
    % CONFIG - Configuration for rank criterion
    %
    % ## Usage synopsis:
    % 
    % import meegpipe.node.bad_channels.criterion.rank.*;
    % cfg = config('key', value, ...);
    %
    % ## Contruction arguments (as key/value pairs):
    %
    %
    %       Percentile : A percentage. Default: [5 90]
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
    %       Min : A numeric scalar. Default: -Inf
    %           Minimum rank index value for a component to be selected.
    %
    %       Max : A numeric scalar. Default: Inf
    %           Maximum rank index value for a component to be selected.
    %
    %
    % ## Notes:
    %
    %   * The MinCard and MaxCard keys will be used in the following way.
    %     First data channels will be sorted according to the distance
    %     between their rank index value and the median rank index value.
    %     Then at least the MinCard most distant channels (and at most the
    %     MaxCard) will be selected as bad.
    %
    %
    % See also: rank
    
    % Documentation: pkg_criterion.txt
    % Description: Configuration for rank criterion
    
    
    properties
 
        MinCard     = 0;
        MaxCard     = Inf;
        Percentile  = [3 95];  
        Min         = -Inf;
        Max         = Inf;
        MADs        = 20;
       
    end
    
     % Consistency checks
    methods
        
        function obj = set.MADs(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                % Set to default
                value = [];
            end
            
            if ~isnumeric(value) || any(value < 0) || numel(value) > 1,
                throw(InvalidPropValue('MADs', ...
                    'Must be a positive scalar'));
            end
            
            obj.MADs = value;
            
        end
        
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
                obj.MaxCard = Inf;
                return; 
            end
            
            if numel(value) ~= 1 || ~isnumeric(value),
                throw(InvalidPropValue('MaxCard', ...
                    'Must be a natural scalar'));
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
            
            if numel(value) ~= 1 || ~isnumeric(value),
                throw(InvalidPropValue('MinCard', ...
                    'Must be a natural scalar'));
            end
            
            obj.MinCard = value;           
            
        end
         
    end
    
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});            
          
            
        end
        
    end
    
    
    
end