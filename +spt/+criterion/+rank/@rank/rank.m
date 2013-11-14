classdef rank < spt.criterion.criterion
    % RANK - Criterion rank (abstract criterion for inheritance)
    %
    % See: <a href="matlab:misc.md_help('spt.criterion.rank')">misc.md_help(''spt.criterion.rank'')</a>
    
    
    % spt.criterion.criterion interface
    methods
        
        [selection, rankIdx] = select(obj, spt, data, ev, rep, varargin);
        
    end
    
    methods (Abstract)
        
        idx = compute_rank(obj, spt, data, sr, ev, rep, raw, varargin)
        
    end    
   
    
end