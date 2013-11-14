classdef psd_ratio < spt.criterion.rank.rank
    % PSD_RATIO - Select components using PSD ratios
    %
    % See: <a href="matlab:misc.md_help('spt.criterion.psd_ratio')">misc.md_help(''spt.criterion.psd_ratio'')</a>

    methods
        
        idx = compute_rank(obj, sptObj, tSeries, sr, ev, rep, varargin);
        
    end
    
    % Constructor
    methods
        
        function obj = psd_ratio(varargin)
            
            obj = obj@spt.criterion.rank.rank(varargin{:});
            
        end
        
    end
    
    
    
end