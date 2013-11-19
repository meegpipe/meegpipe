classdef bss < meegpipe.node.abstract_node
    
    methods (Static, Access = private)       
        make_filtering_report(rep, filtObj, icsIn, icsOut);        
    end
    
    methods (Access = private)
        count = make_pca_report(obj, myPCA);
        count = make_criterion_report(obj, critObj, icSel, isAutoSel);
        bssRep = make_bss_report(obj, bssObj, ics, data);
    end
    
    methods
        
        % node interface
        [data, dataNew] = process(obj, data, varargin);
        
        % Constructor
        function obj = bss(varargin)
            
            import exceptions.*;
            import misc.prepend_varargin;
            
            dataSel = pset.selector.good_data;
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);
            obj = obj@meegpipe.node.abstract_node(varargin{:});            
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'bss');
            end
            
        end
        
    end
    
    
end