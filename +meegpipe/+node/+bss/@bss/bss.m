classdef bss < meegpipe.node.abstract_node
    
    methods (Static, Access = private)
        
        generate_win_report(subRep, sensors, bss, ics, idx, rej);
        generate_rank_report(subRep, critObj, rankIdx, nbSelComp);
        generate_filt_report(subRep, icsIn, icsOut);
        
    end
    
    methods (Access = private)
        make_pca_report(obj, myPCA);
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