classdef bss < meegpipe.node.abstract_node
    
    methods (Static, Access = private)
        make_filtering_report(rep, icsIn, icsOut);
        
        % Used by make_bss_report()
        [maxVar, meanVar] = make_explained_var_report(rep, bss, ics, data, verb, verbL);
        
    end
    
    methods (Access = private)
        
        count = make_pca_report(obj, myPCA);
        
        count = make_criterion_report(obj, critObj, labels, icSel, isAutoSel);
        
        bssRep = make_bss_report(obj, bssObj, ics, data);
        
        extract_bss_features(obj, bssObj, ics, data, icSel);
        
        write_training_data_to_disk(obj, featVal);
        
        % These are called by make_bss_report()
        make_bss_object_report(obj, bss, ics, rep, verb, verbL);
        
        make_spcs_snapshots_report(obj, ics, rep, verb, verbL);        
       
        make_spcs_psd_report(obj, ics, rep, verb, verbL);  
        
        make_spcs_topography_report(obj, bss, ics, data, rep, maxVar, maxAbsVar, verb, verbL);
        
        make_backprojection_report(obj, bss, ics, rep, verb, verbL);
        
    end
    
    methods (Access = protected)
        
        % override from abstract_node
        function bool = has_runtime_config(~)
            bool = true;
        end
        
    end
    
    methods
        
        % node interface
        obj = train(obj, trainInput, varargin);
        
        [data, dataNew] = process(obj, data, varargin);
        
        % own methods
        y = predict_selection(obj, featVal);
      
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