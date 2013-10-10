classdef center < meegpipe.node.abstract_node
    % CENTER - Removes mean of a dataset
    %
    %
    % obj = center;
    %
    % obj = center('key', value, ...)
    %
    %
    % ## Accepted construction arguments:
    %
    % * All the key/value pairs admitted by class abstract_node.
    %
    %
    % See also: abstract_node, node
    
    
    % Documentation: class_center.txt
    % Description: Removes mean from dataset
    
    
    % from abstract_node
    methods
        
        [data, dataNew] = process(obj, data)
        
    end
    
    % Constructor
    methods
        
        function obj = center(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_data_selector(obj));
                set_data_selector(obj, pset.selector.good_data);
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'center');
            end
            
        end
        
    end
    
    
end