classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for psd_ratio criterion
    %
    % See: <a href="matlab:misc.md_help('spt.criterion.psd_ratio.config')">misc.md_help(''spt.criterion.psd_ratio.config'')</a>
    
    properties
        
        Band1;
        Band2;
        % IMPORTANT: this default estimator should match the default
        % estimator in physioset.plotter.psd.config. This allows the
        % user to use the reports to decide the correct values for band1
        % and band2
        Estimator  = @(x, sr) pwelch(x,  min(ceil(numel(x)/5),sr*3), ...
            [], [], sr);
        Band1Stat = @(power) prctile(power, 75);
        Band2Stat = @(power) prctile(power, 25);
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end