classdef abp < meegpipe.node.abstract_node
    % abp - Annotate heartbeats using ECG
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.abp')">misc.md_help(''meegpipe.node.abp'')</a>
        
  
    methods (Static, Access = private)
       [featNames, featVals] = extract_features(data); 
    end
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class __abp__ extract widely known features ' ...
                'from Arterial Blood Pressure time series'];
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = abp(varargin)

            import pset.selector.sensor_label; 
            import misc.prepend_varargin;
            
            dataSel = sensor_label('^BP\s+');
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);  
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
       
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
         
            if isempty(get_name(obj)),
                obj = set_name(obj, 'abp');
            end
            
        end
        
    end
    
    
end