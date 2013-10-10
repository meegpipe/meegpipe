classdef criterion
   % CRITERION - Bad epochs selection criterion interface
   %
   % 
   % See also: pset/node/bad_epochs/criterion
   
   
   
    methods (Abstract)
       
        [evBad, rejIx, samplIdx] = find_bad_epochs(obj, data, ev);
        
    end  
    
end