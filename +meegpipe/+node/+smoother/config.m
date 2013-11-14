classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node smoother
    %
    % ## Usage synopsis:
    %
    % % Create a smoother node that will use a merging window of 0.5 secs
    % import meegpipe.node.smoother.*;
    % myConfig = config('MergeWindow', 0.5);
    % myNode   = smoother(myConfig);
    %
    % % Alternatively
    % myNode = smoother('MergeWindow', 0.5);
    %
    % ## Accepted configuration options:
    %
    % * The bad_channels class constructor admits all the key/value pairs
    %   admitted by the abstract_node class.
    %
    %       MergeWindow : Numeric scalar. Default: 0.1
    %           The length of the data window on which the merging will
    %           take place, in seconds. Making this longer will lead to
    %           smoother results at the expense of increasing the amount of
    %           data that will be distorted by the smoothing process.
    %
    %       EventSelector : A physioset.event.selector object. 
    %           Default: physioset.event.class_selector('Class', 'discontinuity')
    %           A selector that selects the events that mark the 
    %           discontinuities.
    %
    % See also: smoother, chopper
    
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
       
        MergeWindow    = 0.1;
        EventSelector  = ...
            physioset.event.class_selector('Class', 'discontinuity');
        
    end
         
    % Consistency checks
    
    methods
       
        function obj = set.MergeWindow(obj, value)
            
           import exceptions.*;
           
           if isempty(value), 
               value = meegpipe.node.smoother.globals.get.MergeWindow;
           end
           
           if numel(value) ~= 1 || ~isnumeric(value) || value < 0
               throw(InvalidPropValue('MergeWindow', ...
                   'Must be a positive scalar'));
           end
           
           obj.MergeWindow = value;
            
        end
        
        function obj = set.EventSelector(obj, value)
           
            import exceptions.*;
            
            if isempty(value),
                value = physioset.event.class_selector('Class', 'discontinuity');
            end
            
            if numel(value) ~= 1 || ~isa(value, 'physioset.event.selector')
                throw(InvalidPropValue('EventSelector', ...
                    'Must be a physioset.event.event object'));
            end
            
            obj.EventSelector = value; 
            
        end
        
    end
    
     % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
                        
        end
        
    end
    
    
end