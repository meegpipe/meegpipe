classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for thilbert criterion
    %
    % This is a dummy class, as there are no configuration options for
    % criterion thilbert
    %
    % See also: thilbert
 
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end