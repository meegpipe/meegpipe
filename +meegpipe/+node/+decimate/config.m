classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node decimate
    %
    % ## Usage synopsis:
    %
    % % Create a decimate node that reduces the sampling rate by 1/4
    % import meegpipe.node.resample.*;
    % myConfig = config('DownsampleBy', 4);
    % myNode   = resample(myConfig);
    %
    % % Alternatively:
    % myNode = resample('DownsampleBy', 4);
    %
    % ## Accepted configuration options (as key/value pairs):
    % 
    % * The decimate node class admits all the key/value pairs admitted by
    %   the abstract_node node class.
    %       
    %       DownsampleBy : Natural scalar. Default: 1
    %           Downsampling factor
    %
    %       OutputRate: Natural scalar. Default: NaN
    %           The desired output sampling rate. If this config option is
    %           provided, it takes preference over DownsampleBy.
    %
    % See also: decimate
   
    properties
        DownsampleBy = 1;
        OutputRate   = NaN;
    end
    
    
    methods
        
        function obj = set.DownsampleBy(obj, value)
            import misc.isnatural;
            import exceptions.*;
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('DownsampleBy', ...
                    'Must be a natural scalar'));
            end
            
            obj.DownsampleBy = value;
            
        end

        function obj = set.OutputRate(obj, value)

            import misc.isnatural;
            import exceptions.*;

            if numel(value) ~= 1 || (~isnatural(value) && ~isnan(value)),
                throw(InvalidPropValue('OutputRate', ...
                    'Must be a natural scalar or NaN'));
            end

            obj.OutputRate = value;
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            

           
        end
        
    end
    
    
    
end