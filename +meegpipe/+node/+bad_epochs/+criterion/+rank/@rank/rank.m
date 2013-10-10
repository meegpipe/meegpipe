classdef rank < meegpipe.node.bad_epochs.criterion.abstract_criterion
    % RANK - Selects components according to a rank index
    %
    % This is an abstract class that implements common functionality
    % accross classes that select components by ranking them according to a
    % specific "rank index". This is an abstract class designed for
    % inheritance.
    %
    %
    % See also: meegpipe.node.bad_epochs.config

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