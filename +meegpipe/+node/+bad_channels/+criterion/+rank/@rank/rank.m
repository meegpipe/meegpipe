classdef rank < meegpipe.node.bad_channels.criterion.abstract_criterion
    % RANK - Definition of abstract channel rejection criterion rank
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.criterion.rank')">misc.md_help(''meegpipe.node.bad_channels.criterion.rank'')</a>
    
    
 
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