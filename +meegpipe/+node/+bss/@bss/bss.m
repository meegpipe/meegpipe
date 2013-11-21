classdef bss < meegpipe.node.abstract_node
    
    methods (Static, Access = private)       
        
        make_filtering_report(rep, filtObj, icsIn, icsOut);  
        
    end
    
    methods (Access = private)
        
        count = make_pca_report(obj, myPCA);
        
        count = make_criterion_report(obj, critObj, icSel, isAutoSel);
        
        bssRep = make_bss_report(obj, bssObj, ics, data);
        
        % These are called by make_bss_report()
        make_bss_object_report(obj, bss, ics, rep, verb, verbLabel);
        
        make_spcs_snapshots_report(obj, ics, rep, verb, verbLabel);
        
        [statKeys, statVals] = make_explained_var_report(obj, bss, ...
            data, rep, verb, verbLabel);
        
        make_spcs_psd_report(obj, ics, rep, verb, verbLabel);  
        
        make_spcs_topography_report(obj, bss, data, rep, statKeys, statVals, ...
            verb, verbLabel);
        
        make_backprojection_report(obj, bss, ics, rep, verb, verbLabel);
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