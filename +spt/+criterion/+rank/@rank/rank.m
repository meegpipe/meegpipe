classdef rank < spt.criterion.abstract_criterion
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
    
    % Constructor
    methods
        
        function obj = rank(varargin)
            
            obj = obj@spt.criterion.abstract_criterion(varargin{:});
            
        end
        
    end
    
    
    
    
end