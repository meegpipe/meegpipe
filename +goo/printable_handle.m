classdef printable_handle < handle
    % PRINTABLE_HANDLE - Interface for printable (handle) objects
    %
    % See also: printable
    
    methods (Abstract)
       
        count = fprintf(fid, varargin);
        
    end
    
    
    
end