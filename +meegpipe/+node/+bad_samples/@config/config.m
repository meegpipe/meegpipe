classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node bad_samples
    %
    % ## Usage synopsis:
    %
    % % Create a bad_samples node that will reject all samples whose
    % % variance is not within 20 median absolute deviations of the median
    % % sample variance.
    % import meegpipe.node.bad_samples.*;
    % myConfig = config('MADs', 20);
    % myNode   = bad_samples(myConfig);
    %
    % % Alternatively:
    % myNode = bad_samples('MADs', 20);
    %
    % ## Accepted configuration options (as key/value pairs):
    % 
    % * The bad_samples class constructor admits all the key/value pairs
    %   admitted by the abstract_node class.
    %
    %       MADs : Natural scalar. Default: 10
    %           Number of median absolute deviations (MADs) that a sample
    %           needs to depart for being marked as bad. Increasing MADs
    %           will lead to less rejected data samples. 
    %
    %       WindowLength : Natural scalar or function_handle. 
    %           Default: @(fs) fs/2
    %           The parameter WindowLength determines the duration (in
    %           samples) of the analysis windows on which the data variance
    %           is assessed. It can be specified as a fixed number of
    %           samples (a scalar) or as a function of the sampling rate of
    %           the input data (using a function_handle).
    %
    %       WindowShift : Natural scalar or function_handle
    %           Default: @(fs, wl) ceil(wl/20)
    %           The temporal shift (in samples) between correlative
    %           analysis windows. It can a fixed number of samples (a
    %           scalar) or a function_handle taking two arguments: (1) the
    %           sampling rate of the data and (2) the analysis window
    %           length. 
    %
    %       Percentile : A 1x2 vector of percentages. Default: [25 75]
    %           Analysis windows whose variance is not between the
    %           Percentile(1) and Percentile(2) percentiles of the data
    %           variance will be considered to be bad. 
    %
    %       MinDuration : Natural scalar. Default: @(fs) 2*fs
    %           This property can be used to define a minimum duration for
    %           a bad data epoch (in samples). Can be a fixed scalar or a
    %           function_handle taking as unique argument the sampling rate
    %           of the input data.
    %
    %
    % See also: bad_samples
    
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        MADs            = 10;
        WindowLength    = @(fs) fs/2;
        WindowShift     = @(fs, wl) ceil(wl/20);
        Percentile      = [25 75];
        MinDuration     = @(fs) round(fs/2);
        
    end
    
    % Consistency checks
    methods
        
       
        function obj = set.MADs(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                % Set to default
                value = 10;
            end
            
            if ~isnumeric(value) || numel(value) ~= 1 || value < 0,
                throw(InvalidPropValue('MADs', ...
                    'Must be a positive scalar'));
            end
            
            obj.MADs = value;
            
        end
        
        function obj = set.WindowLength(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                value = @(fs) fs/2;
            end
            
            if numel(value) ~= 1 || ...
                    (~isnatural(value) && ~isa(value, 'function_handle')),
               throw(InvalidPropValue('WindowLength', ...
                   'Must be a natural number or a function_handle'));
            end
            
            if isa(value, 'function_handle'),
               % A simple test
               try
                  testVal = value(1000);
               catch ME
                   throw(InvalidPropValue('WindowLength', ...
                       ME.message))
               end
               if ~isnatural(testVal),
                   throw(InvalidPropValue('WindowLength', ...
                       ['Must evaluate to a natural scalar for any ' ...
                       'valid sampling rate']))
               end
            end       
            
            obj.WindowLength = value;
            
        end
        
        function obj = set.WindowShift(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                value = @(fs, wl) ceil(wl/20);
            end
            
            if numel(value) ~= 1 || ...
                    (~isnatural(value) && ~isa(value, 'function_handle')),
               throw(InvalidPropValue('WindowShift', ...
                   'Must be a natural number or a function_handle'));
            end
            
            if isa(value, 'function_handle'),
               % A simple test
               try
                  testVal = value(1000, 100);
               catch ME
                   throw(InvalidPropValue('WindowShift', ...
                       ME.message))
               end
               if ~isnatural(testVal),
                   throw(InvalidPropValue('WindowShift', ...
                       ['Must evaluate to a natural scalar for any ' ...
                       'valid sampling rate and window length']))
               end
            end  
            
            obj.WindowShift = value;
            
        end
        
        function obj = set.Percentile(obj, value)
            
           import exceptions.*;
           
           if isempty(value),
               value = [25 75];
           end
           
           if ~isnumeric(value) || numel(value) ~= 2 || any(value < 0) ...
                   || any(value) > 100,
              throw(InvalidPropValue('Percentile', ...
                  ['Must be a numeric array with two elements, both in ' ...
                  'the range [0,100]']));
           end
           
           obj.Percentile = reshape(value, 1, 2);
           
        end
        
        function obj = set.MinDuration(obj, value)
            
            import exceptions.*;
            import misc.isinteger;
            import misc.isnatural;
            
            if isempty(value),
                value = @(fs) round(fs/2);
            end
            
            if numel(value) ~= 1 || ...
                    (~(isinteger(value) && value >=0) && ...
                    ~isa(value, 'function_handle')),
               throw(InvalidPropValue('MinDuration', ...
                   'Must be a natural number or a function_handle'));
            end
            
            if isa(value, 'function_handle'),
               % A simple test
               try
                  testVal = value(1000);
               catch ME
                   throw(InvalidPropValue('MinDuration', ...
                       ME.message))
               end
               if ~isnatural(testVal),
                   throw(InvalidPropValue('MinDuration', ...
                       ['Must evaluate to a natural scalar for any ' ...
                       'valid sampling rate']))
               end
            end  
            
            obj.MinDuration = value;
        end
        
    end
    
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
           
        end
        
    end
    
    
    
end