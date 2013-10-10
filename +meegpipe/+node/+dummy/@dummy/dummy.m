classdef dummy < meegpipe.node.abstract_node
   % DUMMY - A dummy node, which lets data pass transparently
   %
   % See also: meegpipe.node
    
   methods
        
        [data, dataNew] = process(obj, data)
        
    end
    
    % Constructor
    methods
        
        function obj = dummy(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % Copy constructor
                return;
            end
            
            if isempty(get_data_selector(obj));
                % By default process only the good data
                set_data_selector(obj, pset.selector.good_data);
            end
            
            if isempty(get_name(obj)),
                % Set a default node name
                obj = set_name(obj, 'dummy');
            end
            
        end
        
    end
    
    
end