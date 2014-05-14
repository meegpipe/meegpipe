classdef supervised < spt.criterion.criterion & goo.verbose & goo.abstract_named_object    
       
    properties
        Negated = false;
        Feature = {};
        TrainData; % We keep the train data with the object so that we can re-train
        EnforcePrediction;
    end   
    
    methods
        
        % spt.criterion.criterion interface
        [selected, featVal, rankIdx, obj] = select(obj, objSpt, tSeries, varargin)
        
        count = fprintf(fid, critObj, varargin)
        
        function obj = not(obj)
            obj.Negated = ~obj.Negated;
        end
        
        function bool = negated(obj)
            bool = obj.Negated;
        end
       
        % Constructor
        function obj = supervised(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            % First input args can be features (convenient syntax)
            i = 0;
            while isa(varargin{i+1}, 'spt.feature.feature'),
                i = i + 1;
            end
            opt.Feature = varargin(1:i);
            varargin = varargin(i+1:end);
         
            opt.Negated = false;
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
end