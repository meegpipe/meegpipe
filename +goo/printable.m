classdef printable 
    % PRINTABLE - Interface for printable objects
    %
    % 
    
    methods (Abstract)
       
        count = fprintf(fid, varargin);
        
    end
    
    
    
end