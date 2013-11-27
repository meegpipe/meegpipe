classdef hierarchical_bss < spt.abstract_spt
    
    properties (SetAccess = private, GetAccess = private)
        BSSwin = [];
        WinBoundary = [];
    end
    
    properties
        BSS                = spt.bss.jade;
        DistanceMeasure    = @(obj1, obj2, data) spt.amari_index(projmat(obj1)*bprojmat(obj2));
        SelectionCriterion = ~spt.criterion.dummy;
        DistanceThreshold  = 0;
        NbSurrogatePoints  = 100000;
        NbSurrogates       = 20;
        MaxWindowLength    = @(sr) 20*sr;
    end
    
    methods
        obj = learn_basis(obj, data, varargin);
    end
    
    methods
        
        function obj = hierarchical_bss(varargin)
            import misc.set_properties;
            obj = obj@spt.abstract_spt(varargin{:});
        end
        
    end
    
end