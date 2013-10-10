classdef fix_event_time < meegpipe.node.abstract_node
    % FIX_EVENT_TIME - Fix event times using epochs' cross-correlation
    %
    % import meegpipe.node.mra.mra;
    %
    % obj = fix_event_time('key', value, ...);
    %
    % data = run(obj, data);
    %
    % Where
    %
    % DATA is a physioset object.
    %
    %
    % ## Accepted key/value pairs:
    %
    % * Class fix_event_time node admits all the key/value pairs admitted
    %   by the abstract_node class. For keys specific to this node class 
    %   see: help meegpipe.node.fix_event_time.config
    %
    % See also: config, abstract_node

    %% PUBLIC INTERFACE ...................................................
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class __fix_event_time__ fix event timings ', ...
                'by maximing cross-correlation across event epochs'];
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = fix_event_time(varargin)

            import pset.selector.good_data;

            obj = obj@meegpipe.node.abstract_node(varargin{:});

            if isempty(get_data_selector(obj));
                dataSel = good_data;
                set_data_selector(obj, dataSel);
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'fix_event_time');
            end
          
        end
        
    end
    
    
    
    
    
end