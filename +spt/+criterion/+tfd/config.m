classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for tfd criterion
    %
    %
    % See also: narrowband
    
    % Documentation: pkg_tfd.txt
    % Description: Configuration for tfd criterion
    
    properties
        
        Algorithm    = 'sevcik_mean';
        WindowLength = @(sr) 4*sr;
        WindowShift  = @(sr) sr;
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end