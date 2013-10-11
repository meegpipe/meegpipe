classdef and < ...        
        spt.criterion.criterion     & ...
        goo.verbose                 & ...
        goo.abstract_named_object
    
    properties
        
        Criteria;
        Negated;
        
    end
    
    methods
        
        % spt.criterion.criterion interface
        
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        function bool = negated(obj)
            
            bool = obj.Negated;
            
        end
        
        
        function [selection, rankIdx] = select(obj, varargin)
            
            selection = [];
            rankIdx = [];
            for i = 1:numel(obj.Criteria)
                [thisSel, thisRank] = select(obj.Criteria{i}, varargin{:});
                if i == 1,
                    selection = thisSel; 
                else
                    selection = selection & thisSel;
                end
                rankIdx = [rankIdx thisRank(:)];  %#ok<AGROW>
            end
            
            if obj.Negated,
                selection = ~selection;
            end
            
            rankIdx = sum(rankIdx, 2);
            
            %rankIdx(~selection) = 0;
            
            rankIdx = rankIdx - min(rankIdx);
            
            rankIdx = rankIdx./max(rankIdx);            
            
            
        end
        
        
        
        function obj = and(varargin)
            
            obj.Criteria = varargin;
            
        end
        
    end
    
    
    
end