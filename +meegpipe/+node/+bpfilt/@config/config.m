classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node bpfilt
    %
    % ## Usage synopsis:
    %
    % % Create a bpfilt object that filters between the normalized
    % % frequencies 0.1 and 0.3
    % import meegpipe.node.bpfilt.*;
    % myFilter  = filter.bpfilt('Fp', [0.1 0.3]);
    % myNodeCfg = config('BpFilter', myFilter);
    % myNode    = bpfilt(myNodeCfg);
    %
    % % Or you could have done directly:
    % myFilter  = filter.bpfilt('Fp', [0.1 0.3]);
    % myNode = bpfilt('BpFilter', myFilter);
    % 
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    % * The bpfilt class constructor admits all the key/value pairs
    %   admitted by the abstract_node class.
    %
    %       BpFilter : A filter.bpfilt object
    %           Default: filter.bpfilt (an empty filter object)
    %           The filter that will be used for processing the node input.
    %
    % See also: bpfilt

   
    properties
        
        BpFilt;
        
    end
    
    % Consistency checks
    methods
       
        function obj = set.BpFilt(obj, value)
            import exceptions.*;
            
            if isempty(value), 
                obj.BpFilt = [];
                return;
            end
            
            if ~isa(value, 'filter.bpfilt'),
                throw(InvalidPropValue('BpFilt', ...
                    'Must be a filter.bpfilt object'));
            end
            
            obj.BpFilt = value;           
            
        end
        
    end    
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
             obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end