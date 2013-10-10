classdef chan_interp < meegpipe.node.abstract_node
    % CHAN_INTERP - Bad channel interporlation
    %
    % import meegpipe.node.chan_interp.*;
    % obj = chan_interp;
    % obj = chan_interp('key', value, ...);
    %
    % ## Accepted key/value pairs:
    %
    % * All key/value pairs accepted by abstract_node
    %
    % * All key/value pairs accepted by meegpipe.node.chan_interp.config
    %
    %
    % See also: config, abstract_node

    
    %% PUBLIC INTERFACE ...................................................
    
    
    methods
        % meegpipe.node.node interface
        [data, dataNew] = process(data, varargin);     
    end

    
    % Constructor
    methods
        
        function obj = chan_interp(varargin)
            
            import pset.selector.sensor_class;
            import pset.selector.good_data;
            import pset.selector.cascade;
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            % Default data selector selects only EEG and MEG channels
            dataSel = sensor_class('Class', {'EEG', 'MEG'});           
            
            if isempty(get_data_selector(obj));                
                set_data_selector(obj, dataSel);
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'chan_interp');
            end
            
        end
        
    end
    
    
end