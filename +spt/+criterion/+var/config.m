classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for var criterion
    %
    % See also: var
    
    properties
       
        % Cell array of regular expression or cell arrays of strings
        % Leaving this empty means: all data channels
        ChannelSet; 
        
        % How should the explained variance be aggregated across channels
        % This should be a function handle taking an array of explained
        % variances
        ChannelAggregator;
        
    end
    
    % Consistency checks
    methods
       
        function obj = set.ChannelSet(obj, value)
            import misc.join;
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.ChannelSet = [];
                return;
            end
            
            if ischar(value),
                value = {value};
            end
            
            if ~iscell(value),
                throw(InvalidPropValue('ChannelSet', ...
                    'Must be a cell array'));
            end
            
            for i = 1:numel(value)
               
                if iscell(value{i})
                    isStr = cellfun(@(x) ischar(x), value{i});
                    if ~all(isStr),
                        throw(InvalidPropValue('ChannelSet', ...
                            'Elements of cell array must be strings'));
                    end
                    tmp = join('|', value{i});
                    value{i} = ['^(' tmp ')$'];
                    
                elseif ~ischar(value{i})
                   throw(InvalidPropValue('ChannelSet', ...
                       'Must be a cell array of strings'));
                end
                
            end
                       
            obj.ChannelSet = value;
            
        end
        
        function obj = set.ChannelAggregator(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.ChannelAggregator = @(x) mean(x);
                return;
            end            
           
            if ~isa(value, 'function_handle'),
                throw(InvalidPropValue('ChannelAggregator', ...
                    'Must be a function_handle'));
            end
            
            obj.ChannelAggregator = value;
            
        end
        
    end
  
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
                        
        end
        
    end
    
    
    
end