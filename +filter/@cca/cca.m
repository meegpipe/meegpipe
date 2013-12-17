classdef cca < ...
        filter.dfilt                & ...
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    % CCA - Spatial CCA filtering
    
    
    properties
        
        MaxCorr = 1;
        MinCorr = 0;
        MinCard = 0;
        MaxCard = Inf;
        TopCorrFirst = true;
        CCA = spt.bss.cca;
        % To be applied to the selected canonical components
        CCFilter = []; 
        
    end
    
    
    methods
        % filter.dfilt interface
        [y, obj] = filter(obj, x, varargin);
        
        function [y, obj] = filtfilt(obj, x, varargin)
            
            [y, obj] = filter(obj, x, varargin{:});
            
        end
        
        % Redefinitions of methods from goo.verbose
        function obj = set_verbose(obj, bool)
            obj = set_verbose@goo.verbose(obj, bool);
            if ~isempty(obj.CCFilter),
                obj.CCFilter = set_verbose(obj.CCFilter, bool);
            end
        end
       
    end
    
    % static constructors (default configurations)
    methods (Static)
        function myFilter = bcg_enhance(varargin)
           % BCG_ENCHANGE - Enhance BCG-like activity
           
           import misc.process_arguments;
           import misc.split_arguments;
           
           opt.SamplingRate = [];
           [thisArgs, varargin] = split_arguments(opt, varargin);                                 
           [~, opt] = process_arguments(opt, thisArgs);
           
           if isempty(opt.SamplingRate),
               % Unknown sampling rate. This will not work if you run this
               % filter within a sliding_Window filter
               myCCA = spt.bss.cca('Delay', ...
                   @(data) unique(round(linspace(...
                   data.SamplingRate*0.5, data.SamplingRate*1.2, 30))) ...
                   );
           else
               myCCA = spt.bss.cca('Delay', ...
                   unique(round(linspace(...
                   opt.SamplingRate*0.5, opt.SamplingRate*1.2, 30))) ...
                   );
           end
           
           myCCFilter = filter.tpca(...
               'Order', @(sr) ceil(sr/10), ...
               'PCA',   spt.pca('RetainedVar', 99) ...
               );
           
           myFilter = filter.cca(...
               'CCA',          myCCA, ...
               'CCFilter',     myCCFilter, ...
               'MinCorr',      0.35, ...     
               'TopCorrFirst', true, ...
               'Name',         'filter.cca.bcg_enhance', ...
               varargin{:} ...
               );
        end
    end
    
    % Constructor
    methods
        
        function obj = cca(varargin)
            
            import misc.process_arguments;
            
            opt.MaxCorr = 1;
            opt.MinCorr = 0;
            opt.MinCard = 0;
            opt.MaxCard = Inf;
            opt.CCA = spt.bss.cca;
            opt.TopCorrFirst = true;
            opt.CCFilter = [];
            opt.Name     = 'filter.cca';
            opt.Verbose  = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.MaxCorr = opt.MaxCorr;
            obj.MinCorr = opt.MinCorr;
            obj.MinCard = opt.MinCard;
            obj.MaxCard = opt.MaxCard;
            obj.CCA = opt.CCA;
            obj.CCFilter = opt.CCFilter;
            obj.TopCorrFirst = opt.TopCorrFirst;
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end   
    
   
end