classdef criterion
   % CRITERION - Interface for spatial components selection criteria
   
 
    methods (Abstract)
        
        [selection, rankIndex] = select(obj, spt, ics, raw, rep, varargin);
        
        obj = not(obj);
        
        bool = negated(obj);        
      
    end
    
    
end