classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for tkurtosis criterion
    %
    % This is a dummy class, as there are no configuration options for
    % criterion tgini
    %
    % See also: tgini
    
    % Documentation: pkg_tkurtosis.txt
    % Description: Configuration for tkurtosis criterion
  
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end