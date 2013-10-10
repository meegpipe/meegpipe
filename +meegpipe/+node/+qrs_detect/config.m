classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of qrs_detect nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.qrs_detect.config')">misc.md_help(''meegpipe.node.qrs_detect.config'')</a>
    
    
    
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Event      = physioset.event.std.qrs;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Event(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                value = physioset.event.std.qrs;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'physioset.event.event')
                throw(InvalidPropValue('Event', ...
                    'Must be a physioset.event.event object'));
            end
            
            obj.Event = value;
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end