classdef periodic_generator < physioset.event.generator & ...
        goo.abstract_setget
    % PERIODIC_GENERATOR - Generate periodic events
    %
    % See also: physioset.event
    
    properties
        
        StartTime = 0;    % In seconds from beginning of recording
        Period    = 10;   % In seconds
        Template  = @(sampl, idx) physioset.event.event(sampl, ...
            'Type', '_PeriodicEvent', 'Value', idx);
        
    end
    
    
    methods
        
        % Consistency checks
        
        function obj = set.StartTime(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.StartTime = 0;
                return;
            end
            
            if ~isnumeric(value) || numel(value) ~= 1 || value < 0,
                throw(InvalidPropValue('StartTime', ...
                    'Must be a positive scalar'));
            end
            
            obj.StartTime = value;
            
        end
        
        function obj = set.Period(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Period = 10;
                return;
            end
            
            if ~isnumeric(value) || numel(value) ~= 1 || value < 0,
                throw(InvalidPropValue('Period', ...
                    'Must be a positive scalar'));
            end
            
            obj.Period = value;
            
        end
        
        function obj = set.Template(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Template = ...
                    @(sampl, idx) physioset.event.event(...
                    sampl, 'Type', '_PeriodicEvent', 'Value', idx);
                return;
            end
            
            if ~isa(value, 'function_handle'),
                throw(InvalidPropValue('Template', ...
                    'Must be a function_handle'));
            end
            
            try
                toy = value(10, 1);
                if ~isa(toy, 'physioset.event.event'),
                    throw(InvalidPropValue('Template', ...
                        'Template must evaluate to an event object'));
                end
            catch ME
                if strcmp(ME.identifier, 'MATLAB:TooManyInputs'),
                    throw(InvalidPropValue('Template', ...
                        'Template must take two arguments'));
                else
                    rethrow(ME);
                end
            end
            
            obj.Template = value;
            
        end
        
        
        % physioset.event.generator interface
        
        function evArray = generate(obj, data, varargin)
            
            import physioset.event.event;
            
            period = ceil(obj.Period*data.SamplingRate);
            startTime = max(1, ceil(obj.StartTime*data.SamplingRate));
            
            sampl = startTime:period:size(data,2);
            
            evArray = obj.Template(sampl(1), 1);
            evArray = repmat(evArray, 1, numel(sampl));
            for i = 2:numel(sampl)
                evArray(i) = obj.Template(sampl(i), i);
            end
        end
        
        % Constructor
        
        function obj = periodic_generator(varargin)
            
            import misc.process_arguments;
            
            opt.StartTime = 0;
            opt.Period    = 10;
            opt.Template  = [];
            
            % We keep this for backwards compatibility
            opt.Type     = [];
            opt.Duration = [];
            opt.Offset   = [];
            
            [~, opt] = process_arguments(opt, varargin);
            
            if ~isempty(opt.Type) || ~isempty(opt.Duration) || ...
                    ~isempty(opt.Offset),
                warning('periodic_generator:Obsolete', ...
                    ['Construction arguments Type, Duration, Offset ' ...
                    'have been deprecated. Use Template instead.']);
                
                if ~isempty(opt.Template),
                    error(['Cannot use Template together with any of ' ...
                        'Type, Duration, Offset']);
                end
                
                opt.Type     =  '__PeriodicEvent';
                opt.Duration = 1;
                opt.Offset   = 0;
                [~, opt] = process_arguments(opt, varargin);
                obj.Template = @(sampl, idx) physioset.event.event(...
                    'Type', opt.Type, 'Duration', opt.Duration, ...
                    'Offset', opt.Offset);                
            else
                
                if isempty(opt.Template),
                    opt.Template =  ...
                        @(sampl, idx) physioset.event.event(sampl, ...
                        'Type', '_PeriodicEvent', 'Value', idx);
                end                
            end            
            obj.Template = opt.Template;
            obj.Period    = opt.Period;
            obj.StartTime = opt.StartTime;
        end
        
    end
    
end