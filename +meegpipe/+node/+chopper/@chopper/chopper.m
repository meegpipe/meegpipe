classdef chopper < meegpipe.node.abstract_node
    % CHOPPER - Chops input data into various analysis windows
    %
    % obj = chopper;
    %
    % obj = chopper('key', value, ...);
    %
    % data = process(obj, data);
    %
    % Where
    %
    % DATA is a physioset object.
    %
    %
    % ## Accepted key/value pairs:
    %
    % * The chopper class admits all the key/value pairs admitted by the
    %   abstract_node class. For detrend-specific keys see the help of
    %   meegpipe.node.detrend.config.
    %
    % See also: config, abstract_node
    
    % Documentation: class_chopper.txt
    % Description: Chops data into various analysis windows
    
    %% IMPLEMENTATION .....................................................
    
    methods (Static, Access = private)
        
        generate_index_report(rep, data, idx, bndry);
        
    end
    
    %% PUBLIC INTERFACE ...................................................
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class _chopper_ chop the input data ' ...
                'into correlative analysis windows.'];
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = chopper(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_data_selector(obj));
                set_data_selector(obj, pset.selector.good_data);
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'chopper');
            end
            
        end
        
    end
    
    
end