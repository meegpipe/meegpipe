classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node bad_epochs
    %
    % ## Usage synopsis:
    %
    % % Create a bad_epochs node that will reject all epochs whose
    % % kurtosis is beyond 5 median absolute deviations of the median
    % % epochs' kurtosis
    % import meegpipe.node.bad_epochs.*;
    % myCriterion = criterion.kurtosis.config('MADs', 5);
    % myNode      = bad_epochs('Criterion', myCriterion);
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    % * The bad_channels class constructor admits all the key/value pairs
    %   admitted by the abstract_node class.
    %
    %       Criterion : A criterion.criterion object. 
    %           Default: criterion.minmax.minmax
    %           A data epochs rejection criterion. This is where the
    %           actual rejection is implemented.    
    %
    % See also: bad_epochs, abstract_node
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Duration        = 1;
        Offset          = 0;
        EventSelector   = ...
            physioset.event.class_selector('Class', physioset.event.std.trial_begin);        
        Criterion       = meegpipe.node.bad_epochs.criterion.stat.stat;
    end
    
    % Consistency checks
    methods
       
        function obj = set.Criterion(obj, value)
            
            import exceptions.*;

            if isempty(value),
                % Set to default
                value = meegpipe.node.bad_epochs.criterion.var.var;
            end
            
            if ~isa(value, 'meegpipe.node.bad_epochs.criterion.criterion'),
                throw(InvalidPropValue('Criterion', ...
                    'Must be a criterion object'));
            end
            
            obj.Criterion = value;
            
        end    
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
                        
        end
        
    end
    
    
    
end