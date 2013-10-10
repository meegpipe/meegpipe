classdef rank < meegpipe.node.bad_channels.criterion.abstract_criterion
    % RANK - Selects components according to a rank index
    %
    % This is an abstract class that implements common functionality
    % accross classes that select components by ranking them according to a
    % specific "rank index". This class designed for inheritance.
    %
    %
    % See also: config
    
 
    % criterion interface
    methods
       
        [idx, rankVal] = find_bad_channels(obj, data);
        
    end  
    
    methods (Abstract)
        
        idx = compute_rank(obj, data)
        
    end
    
    % Constructor
    methods
        
        function obj = rank(varargin)
            
          
            obj = ...
                obj@meegpipe.node.bad_channels.criterion.abstract_criterion(...
                varargin{:});
          
        end
        
    end
    
    
    
    
end