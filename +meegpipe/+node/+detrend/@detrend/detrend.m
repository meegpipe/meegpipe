classdef detrend < meegpipe.node.abstract_node
    % DETREND - Removes low frequency trends
    %
    % obj = detrend;
    %
    % obj = detrend('key', value, ...)
    %
    % data = process(obj, data);
    %
    %
    % Where
    %
    % DATA is a physioset object.
    %
    %
    % ## Accepted key/value pairs:
    %
    % * The detrend class admits all the key/value pairs admitted by the
    %   abstract_node class. For detrend-specific keys see the help of
    %   meegpipe.node.detrend.config.
    %
    % See also: config, abstract_node
    
    properties (GetAccess = private, Constant)
        NbChannelsReport = 5;        
    end

    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class _detrend_ remove low frequency trends ' ...
                'from the input data.'];
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = detrend(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            warning('detrend:Obsolete', ...
                'The detrend node is obsolete and will be removed in future versions');
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_data_selector(obj));
                set_data_selector(obj, pset.selector.good_data);
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'detrend');
            end
            
            
        end
        
    end
    
    
end