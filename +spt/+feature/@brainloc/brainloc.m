classdef brainloc < spt.feature.feature & goo.verbose
    % BRAINLOC - Brain localization of a SPT component
    
    properties
       HeadModel;
       InverseSolver;
    end
    
    methods
        
        % spt.feature.feature interface
        [idx, featName] = extract_feature(obj, sptObj, tSeries, raw, rep, varargin)
        
        % Constructor        
        function obj = brainloc(varargin)
            import misc.set_properties;            

            evalc('opt.HeadModel = make_bem(head.mri)');
            opt.InverseSolver   = 'dipfit';           
            obj = set_properties(obj, opt, varargin);
        end
        
    end
    
    
    
end