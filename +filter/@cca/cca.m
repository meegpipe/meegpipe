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
        ComponentFilter  = [];
        TopCorrFirst = true;
        CCA = spt.bss.cca;
        
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
            if ~isempty(obj.ComponentFilter),
                obj.ComponentFilter = set_verbose(obj.ComponentFilter, bool);
            end
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
            opt.ComponentFilter = [];
            opt.Name     = 'filter.cca';
            opt.Verbose  = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.MaxCorr = opt.MaxCorr;
            obj.MinCorr = opt.MinCorr;
            obj.MinCard = opt.MinCard;
            obj.MaxCard = opt.MaxCard;
            obj.CCA = opt.CCA;
            obj.ComponentFilter = opt.ComponentFilter;
            obj.TopCorrFirst = opt.TopCorrFirst;
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end   
    
   
end