classdef thilbert < spt.criterion.rank.rank
    % THILBERT - Selects components that look like Amp-modulated sinusoids
       
  
    % criterion.rank.rank
    methods
        
        idx = compute_rank(obj, spt, data, varargin)
        
    end
   
    % Constructor
    methods
        function obj = thilbert(varargin)                      

            obj = obj@spt.criterion.rank.rank(varargin{:});     
        end
    end
    
    
    
end