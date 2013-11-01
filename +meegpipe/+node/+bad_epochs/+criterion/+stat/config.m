classdef config < meegpipe.node.bad_epochs.criterion.rank.config
    % CONFIG - Configuration for bad epochs rejection criterion stat
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_epochs.criterion.stat.config')">misc.md_help(''meegpipe.node.bad_epochs.criterion.stat.config'')</a>
    
    
    
    properties
        
        ChannelStat = @(x) max(abs(x)); % Across time within an epoch
        EpochStat   = @(x) max(x);      % Across channel stats
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.bad_epochs.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end