classdef config < meegpipe.node.bad_channels.criterion.rank.config
    % CONFIG - Configuration for bad_channels variance criterion
    %
    % This config class is not intended to be used directly. It implements
    % consistency checks required for the construction of a valid 
    % meegpipe.node.bad_channels.criterion.var.var object. The 
    % configuration options listed below can be passed as key/value 
    % arguments during the construction of a var criterion object.
    %
    % ## Usage synopsis:
    %
    % % Create a bad_samples node that will reject all channels whose
    % % variance is not within 20 median absolute deviations of the median
    % % channel variance.
    % import meegpipe.node.bad_channels.criterion.var.config;
    % import meegpipe.node.bad_channels.criterion.var.var;
    % myConfig = config('NN', 10);
    % myCrit   = var(myConfig);
    %
    % % Alternatively:
    % myCrit = var('NN', 10);
    %
    % % Once the criterion has been constructed, you can feed it to the
    % % constructor of a bad_channels node:
    % import meegpipe.node.bad_channels.bad_channels;
    % myNode = bad_channels('Criterion', myCrit);
    % 
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    % * The var criterion constructor admits all the key/value pairs
    %   admitted by the rank criterion constructor. See:
    %   help meegpipe.node.bad_channels.criterion.rank.config
    %   
    %
    %       NN : Numeric scalar. Default: 10
    %           Number of nearest neighbor sensors to consider when
    %           calculating local data variances.
    %
    %       Filter : A filter.dfilt object. Default: []
    %           The data will be pre-filtered using this filter before
    %           computing the data variances.
    %
    %       Normalized : Logical scalar. Default: true
    %           If set to true, the output of the filter will be scaled
    %           according to the unfiltered variance of each channel. 
    %
    % See also: var, bad_channels, abstract_node
    
   
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        NN              = 10;
        Filter          = [];
        Normalize       = true;
        LogScale        = true;
        
    end
    
    % Consistency checks
    methods
       
       
        function obj = set.NN(obj, value)
           
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                value = 10;
            end
            
            if numel(value) > 1,
                throw(InvalidPropValue('NN', ...
                    'Must be a numeric scalar'));
            end
            
            obj.NN = ceil(value);
            
        end
        
        function obj = set.Filter(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.Filter = [];
                return;
            end
            
            if ~isa(value, 'function_handle') && ...
                    ~isa(value, 'filter.dfilt'),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.dfilt object'));
            end
            
            obj.Filter = value;
            
        end
        
        function obj = set.Normalize(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                % Default
                value = true;
            end
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Normalize', ...
                    'Must be a logical scalar'));
            end
            
            obj.Normalize = value;
            
        end
        
        function obj = set.LogScale(obj, value)
           
            import exceptions.*;
            
            if isempty(value),
                % Default
                value = true;
            end
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Normalize', ...
                    'Must be a logical scalar'));
            end
            
            obj.LogScale = value;
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            import misc.process_arguments;
            
            obj = obj@meegpipe.node.bad_channels.criterion.rank.config(...
                varargin{:});
            
             if nargin == 1, 
                 % Copy constructor!
                 return; 
             end
             
             opt.Min = @(x) median(x) - 20; 
             opt.Max = @(x) median(x) + 20*mad(x);
            
             [~, opt] = process_arguments(opt, varargin);
             
             fNames = fieldnames(opt);
             for i = 1:numel(fNames)
                 set(obj, fNames{i}, opt.(fNames{i}));
             end
                        
        end
        
    end
    
    
    
end