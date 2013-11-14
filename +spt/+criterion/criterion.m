classdef criterion
   % CRITERION - Interface for spatial components selection criteria
   %
   % See also: spt.criterion
   
 
    methods (Abstract)
        
        [selection, rankIndex] = select(obj, spt, ics, ev, rep, raw, varargin);
        
        obj = not(obj);
        
        bool = negated(obj);        
      
    end
    
    
end