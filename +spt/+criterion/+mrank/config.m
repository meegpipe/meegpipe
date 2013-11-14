classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for mrank criterion
    %
    % See also: mrank
    
    % Documentation: pkg_criterion.txt
    % Description: Configuration for mrank criterion
    
   
    properties
        
        Criteria;
        Weights;
        
    end    
     
    methods (Access = private)
        
        function check(obj)
            
            if numel(obj.Weights) ~= numel(obj.Criteria),
                error(['The number of weights (%d) is not consistent ' ...
                    'with the number of criteria (%d)'], ...
                    numel(obj.Weights), numel(obj.Criteria));
            end
            
        end
        
    end

    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
            if isempty(obj.Weights) && numel(obj.Criteria) > 0,
                
                obj.Weights = ...
                    ones(1, numel(obj.Criteria))/numel(obj.Criteria);                
         
            end       
            
            check(obj);
            
        end
        
    end
    
    
    
end