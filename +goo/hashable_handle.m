classdef hashable_handle < handle
   % HASHABLE - Interface for hashable handle classes
   %
   % A class is hashable if an MD5 hash can be produced to identify its
   % objects' data. Namely, hashable classes need to implement the
   % following method:
   %
   % hash = get_hash_code(obj)
   %
   % Where
   %
   % HASH is the MD5 hash (a string of 32 characters).
   %
   % See also: hashable
   
   methods (Abstract)
       
       hash = get_hash_code(obj);
       
   end
    
    
    
    
end