classdef amica < spt.abstract_spt
    
    properties
        NbMixtures  = 3;
        MaxIter     = 500;
        UpdateRho   = true;
        MinLL       = 1e-8;
        IterWin     = 50;
        DoNewton    = true;
    end
    
    methods
        data = learn_basis(obj, data, varargin);
    end
    
    methods
        function obj = amica(varargin)
            import misc.set_properties;
            obj = obj@spt.abstract_spt(varargin{:});
            
            opt.NbMixtures  = 3;
            opt.MaxIter     = 500;
            opt.UpdateRho   = true;
            opt.MinLL       = 1e-8;
            opt.IterWin     = 50;
            opt.DoNewton    = true;
            obj = set_properties(obj, opt, varargin{:});
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'amica');
            end
            
        end
    end
    
end