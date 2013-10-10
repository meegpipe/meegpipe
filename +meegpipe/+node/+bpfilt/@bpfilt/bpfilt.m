classdef bpfilt < meegpipe.node.abstract_node
    % BPFILT - Band pass filter node
    %
    % obj = bpfilt('key', value, ...)
    %
    %
    % Where
    %
    % OBJ is an meegpipe.node.bpfilt object
    %
    %
    % ## Accepted key/value pairs:
    %
    % * All key/value pairs accepted by the contructor of filter.bpfilt
    %   objects
    %
    % * All key/value pairs accepted by aar.node.abstract_node
    %
    %
    % See also: filter.bpfilt
    
   
    %% PUBLIC INTERFACE ...................................................
    
    
    % meegpipe.node.node interface
    methods
        
        % does something extra on top of abstract_node's method
        [data, dataNew] = process(obj, file, varargin)
        
    end   
    
    
    % Constructor
    methods
        
        function obj = bpfilt(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            warning('bpfilt:obsolete', ...
                'bpfilt nodes are deprecated in favor of tfilter nodes');
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
       
            if isempty(get_data_selector(obj));               
                set_data_selector(obj, pset.selector.good_data);
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'bpfilt');
            end
            
        end
        
    end
end