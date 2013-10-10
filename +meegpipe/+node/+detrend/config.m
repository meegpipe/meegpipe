classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node detrend
    %
    % ## Usage synopsis:
    %
    % % Create a detrend node that will use a polynomial fit of order 10
    % import meegpipe.node.detrend.*;
    % myConfig = config('PolyOrder', 10);
    % myNode   = detrend(myConfig);
    %
    % % Alternatively:
    % myNode = detrend('PolyOrder', 10);
    %
    % ## Accepted configuration options (as key/value pairs):
    % 
    % * The detrend class admits all the key/value pairs admitted by the
    %   abstract_node class.
    %
    %       PolyOrder  : Natural scalar. Default: 10
    %           Order of the polynomial fit.
    %               
    %       Decimation : Natural scalar. Default: 10
    %           The decimation factor to be applied before performing the
    %           actual polynomial fit.
    %
    % See also: detrend

    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        PolyOrder    = 10;
        Decimation   = 10;
        ChopSelector = []; 
        ExpandBoundary = false;
        
    end
    
    % Consistency checks (to be done...)
    methods
        
        function obj = set.PolyOrder(obj, value)
            
            import misc.isnatural;
            import exceptions.*;
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('PolyOrder', ...
                    'Must be a natural scalar'));
            end
            
            obj.PolyOrder = value;
            
        end
        
        function obj = set.Decimation(obj, value)
                
            import misc.isnatural;
            import exceptions.*;
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('Decimation', ...
                    'Must be a natural scalar'));
            end
            
            obj.Decimation = value;
            
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
           
        end
        
    end
    
    
    
end