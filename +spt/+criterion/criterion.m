classdef criterion < goo.abstract_named_object & goo.printable & goo.hashable
    % CRITERION - Interface for spatial components selection criteria
    
    
    methods (Abstract)
        
        [selection, featVal, rankIdx, obj] = select(obj, spt, ics, raw, rep, varargin);
        
        obj  = not(obj);
        
        bool = negated(obj);
 
    end
    
    methods
        
        function obj  = reorder(obj, ~)  %#ok<MANU>
           
            import exceptions.NotImplemented;
            throw(NotImplemented);
            
        end       
        
    end
    
    
end