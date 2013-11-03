classdef bad_samples < meegpipe.node.abstract_node
    % BAD_SAMPLES - Bad sample rejection
    %
    % obj = bad_samples('key', value, ...)
    %
    %
    % ## Accepted key/value pairs:
    %
    % * All key/value pairs accepted by meegpipe.node.abstract_node
    %
    % * See help meegpipe.node.bad_samples.config for keys specific to this
    %   class.
    %
    %
    % See also: config, abstract_node, meegpipe.node
    
    %% IMPLEMENTATION .....................................................
    methods (Access = private, Static)
        
        generate_var_report(rep, isRej, topVar, lowVar, mVL, mxVL, mVT, mxVT);
        
    end
    
    methods (Access = private)
        
        idx = find(obj, data, mads, wl, ws, perc, minDur);
        
    end
    
    %% PUBLIC INTERFACE ...................................................
    
    % meegpipe.node.node interface
    methods
        
        [data, dataNew] = process(data, varargin);
        
    end
  
    % Constructor
    methods
        
        function obj = bad_samples(varargin)
            import pset.selector.sensor_class;
            import pset.selector.good_data;
            import pset.selector.cascade;
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            warning('bad_samples:SoonObsolete', ...
                ['Node bad_samples is obsolete and will be ' ...
                'removed in future versions of meegpipe. Use a ' ...
                'bad_epochs node instead.']);
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end            
            
            if isempty(get_data_selector(obj));
                % Default data selector selects only EEG and MEG channels
                dataSel1 = sensor_class('Class', {'EEG', 'MEG'});
                dataSel2 = good_data;
                dataSel  = cascade(dataSel1, dataSel2);
                set_data_selector(obj, dataSel);
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'bad_samples');
            end
            
        end
        
    end
end