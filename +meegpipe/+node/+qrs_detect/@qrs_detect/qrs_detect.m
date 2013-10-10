classdef qrs_detect < meegpipe.node.abstract_node
    % qrs_detect - QRS complex detection
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.qrs_detect')">misc.md_help(''meegpipe.node.qrs_detect'')</a>
    
    
    
    
    %% PUBLIC INTERFACE ...................................................
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class __qrs_detect__ identify the locations ' ...
                'of QRS complexes. Such locations are marked with '  ...
                'suitable events introduced into the input physioset.'];
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = qrs_detect(varargin)
            
            import pset.selector.cascade;
            import pset.selector.good_data;
            import pset.selector.sensor_class;
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_data_selector(obj));
                dataSel = cascade(good_data, sensor_class('Type', 'ECG'));
                set_data_selector(obj, dataSel);
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'qrs_detect');
            end
            
        end
        
    end
    
    
end