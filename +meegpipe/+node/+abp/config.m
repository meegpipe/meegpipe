classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of abp nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.abp.config')">misc.md_help(''meegpipe.node.abp.config'')</a>
   
    properties
       
        RPeakEventSelector = physioset.event.class_selector('Class', 'qrs');
        
    end
   
        % Consistency checks
    methods     
       
        function obj = set.RPeakEventSelector(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.RPeakEventSelector = [];
                return;
            end
            
            if ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('RPeakEventSelector', ...
                    'Must be a cell array of event selectors'));
            end
            
            obj.RPeakEventSelector = value;          
            
        end
  
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end