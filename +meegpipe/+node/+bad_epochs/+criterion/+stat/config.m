classdef config < meegpipe.node.bad_epochs.criterion.rank.config
    % CONFIG - Configuration for criterion stat
    %
    % ## Usage synopsis:
    % 
    % % Create a stat criterion object with default configuration
    % import meegpipe.node.bad_epochs.criterion.stat.*;
    % myCfg  = config;
    % myCrit = stat(myCfg);
    %
    % % Create a criterion with custom configuration
    % myCfg  = config('Percentile', [5 95]);
    % myCrit = stat(myCfg);
    %
    % % Our you could simply do:
    % myCrit = stat('Percentile', [5 95]);
    %
    %
    % ## Accepted (optional) construction key/value pairs:
    %
    %   * All key/value pairs accepted by parent class
    %     meegpipe.node.bad_epochs.criterion.rank.config
    %
    %       Statistic1 : A function_handle. Default: @(x) max(abs(x))
    %           Within-epoch statistic. This statistic is used to extract a
    %           single feature from every epoch realization.
    %
    %       Statistic2 : A function_handle. Default: @(x) max(x)
    %           Across-channels statistic. This statistic is used to 
    %           summarize within-epoch statistics across all channels.
    %
    % 
    % See also: config
    
    %% PUBLIC INTERFACE ...................................................
    
    properties        
        
        Statistic1 = @(x) max(abs(x)); % Across time within an epoch
        Statistic2 = @(x) max(x);      % Across data channels
        
    end
    
    % Consistency checks
    methods
        
        % To be done
    
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.bad_epochs.criterion.rank.config(varargin{:});
                        
        end
        
    end
    
    
    
end