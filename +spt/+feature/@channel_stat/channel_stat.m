classdef channel_stat < spt.feature.feature & goo.verbose
    
    
    properties
        
        TargetSelector  = pset.selector.all_data;
        ChannelStat     = @(x) var(x, [], 2);
        AggregatingStat = @(x) mean(x);
        
    end
    
    methods
        
        idx = extract_feature(obj, sptObj, tSeries, raw, varargin)     
        
        % Constructor
        
        function obj = channel_stat(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.TargetSelector  = pset.selector.all_data;
            opt.ChannelStat     = @(x) var(x, [], 2);
            opt.AggregatingStat = @(x) mean(x);
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
end