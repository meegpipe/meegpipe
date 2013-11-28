classdef hierarchical_bss < spt.abstract_spt
    
    methods (Access = private)
       
        [bssArray, winBndry] = learn_lr_basis(obj, data, bssCentroid, winBndry);
        
    end
    
    properties (SetAccess = private, GetAccess = private)
        WinBoundary = [];
    end
    
    properties
        BSS                = spt.bss.jade;
        DistanceMeasure    = @(obj1, obj2, data) spt.amari_index(projmat(obj1)*bprojmat(obj2), 'range', [0 100]);
        SelectionCriterion = ~spt.criterion.dummy;
        DistanceThreshold  = 1;
        ParentSurrogates   = 10;
        ChildrenSurrogates = 20;
        Surrogator         = surrogates.shuffle;
        MaxWindowLength    = @(sr) 20*sr;
        FixNbComponents    = @(nbComponents) max(nbComponents);
        Overlap            = [0 5 10 25 50];
    end
    
    methods
        
        function obj = set.Surrogator(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Surrogator = surrogates.shuffle;
                return;
            end
            
            if ~isa(value, 'surrogates.surrogator'),
                throw(InvalidPropValue('Surrogator', ...
                    'Must be a surrogates.surrogator object'));
            end
            obj.Surrogator = value;
            
        end
        
    end
    
    methods
        % Declared (but not defined) by abstract_spt
        obj = learn_basis(obj, data, varargin);
        
        % Redefinitions of abstract_spt methods
        W = projmat(obj, full);
        A = bprojmat(obj, full);
        
        % Declared and defined here
        bndry = window_boundary(obj);
    end
    
    methods
        
        function obj = hierarchical_bss(varargin)
            import misc.set_properties;
            import misc.split_arguments;
            
            % Pick the BSS algorithm
            if nargin > 0 && isa(varargin{1}, 'spt.spt'),
                varargin = [{'BSS'}, varargin];
            end
            
            opt.BSS                = spt.bss.jade;
            opt.DistanceMeasure    = @(obj1, obj2, data) spt.amari_index(projmat(obj1)*bprojmat(obj2), 'range', [0 100]);
            opt.SelectionCriterion = ~spt.criterion.dummy;
            opt.DistanceThreshold  = 1;
            opt.ParentSurrogates   = 10;
            opt.ChildrenSurrogates = 20;
            opt.Surrogator         = surrogates.shuffle;
            opt.MaxWindowLength    = @(sr) 20*sr;
            opt.FixNbComponents    = @(nbComponents) max(nbComponents);
            opt.Overlap            = [0 5 10 25 50];
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});
            
            obj = set_properties(obj, opt, thisArgs);
        end
        
    end
    
end