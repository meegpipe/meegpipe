classdef spt < meegpipe.node.abstract_node
    % SPT - Apply spatial transform
    
  
    % meegpipe.node.node interface
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % Constructor
    methods
        function obj = spt(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                sptObj = get_config(obj, 'SPT');
                if isempty(sptObj),
                    obj = set_name(obj, 'spt');
                elseif ~isempty(get_name(sptObj)),
                    obj = set_name(obj, get_name(sptObj)); 
                else
                    obj = set_name(obj, 'spt');
                end
            end
            
        end
    end
    
    
end