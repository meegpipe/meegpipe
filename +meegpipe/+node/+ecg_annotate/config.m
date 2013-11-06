classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of ecg_annotate nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.ecg_annotate.config')">misc.md_help(''meegpipe.node.ecg_annotate.config'')</a>
    
    properties        
       
        EventSelector  = []; 
        RPeakEventSelector = physioset.event.class_selector('Class', 'qrs');
        
    end
    
    % Consistency checks
    methods
       
        function obj = set.EventSelector(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.EventSelector = [];
                return;
            end
            
            if isa(value, 'physioset.event.selector'),
                value = {value};
            end
            
            if ~iscell(value) || ~all(cellfun(@(x) ...
                    isa(x, 'physioset.event.selector'), value)),
                throw(InvalidPropValue('EventSelector', ...
                    'Must be a cell array of event selectors'));
            end
            
            obj.EventSelector = value;          
            
        end
        
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