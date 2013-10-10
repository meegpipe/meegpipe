classdef criterion
   % CRITERION - Bad channels selection criterion interface
   %
   % 
   % See also: meegpipe.node.bad_channels.criterion
   
    methods (Abstract)
       
        [idx, rankVal] = find_bad_channels(obj, data);
        
    end  
    
end