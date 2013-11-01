classdef rank < meegpipe.node.bad_epochs.criterion.abstract_criterion
    % RANK - Definition of abstract epoch rejection criterion rank
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_epochs.criterion.rank')">misc.md_help(''meegpipe.node.bad_epochs.criterion.rank'')</a>
    

    methods (Static, Access = private)
       generate_rank_report(rep, rankIndex, rejIdx, minRank, maxRank); 
       hFig = make_rank_plots(rankIndex, rejIdx, minRank, maxRank)
    end
   
    % criterion interface
    methods
       
        [evBad, rejIdx, samplIdx] = find_bad_epochs(obj, data, ev, varargin);
        
    end  
    
    methods (Abstract)
        
        [idx, ev] = compute_rank(obj, data, ev, varargin)
        
    end
    
    % Constructor
    methods
        
        function obj = rank(varargin)
           
            obj = ...
                obj@meegpipe.node.bad_epochs.criterion.abstract_criterion(...
                varargin{:});
          
        end
        
    end
    
    
    
    
end