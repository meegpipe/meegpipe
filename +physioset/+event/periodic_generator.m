classdef periodic_generator < physioset.event.generator & ...
        goo.abstract_setget
    % PERIODIC_GENERATOR - Generate periodic events
    %
    % See also: physioset.event
    
    properties
        
        StartTime = 0;    % In seconds from beginning of recording
        Period    = 10;   % In seconds
        Type      = '__PeriodicEvent';
        Duration  = 0;    % In seconds
        Offset    = 0;    % In seconds
        
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
        
        
        % physioset.event.generator interface
        
        function evArray = generate(obj, data, varargin)
            
            import physioset.event.event;
            
            period = ceil(obj.Period*data.SamplingRate);
            startTime = max(1, ceil(obj.StartTime*data.SamplingRate));
            
            evArray = event(startTime:period:size(data,2), ...
                'Type',     obj.Type, ...
                'Offset',   round(obj.Offset*data.SamplingRate), ...
                'Duration', ceil(obj.Duration*data.SamplingRate));
            
        end
        
        % Constructor
        
        function obj = periodic_generator(varargin)
            
            import misc.process_arguments;
            
            opt.StartTime = 0;
            opt.Period = 10;
            opt.Type  =  '__PeriodicEvent';
            opt.Duration = 0;
            opt.Offset = 0;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Period = opt.Period ;
            obj.Type  =  opt.Type;
            obj.Duration = opt.Duration;
            obj.Offset = opt.Offset;
            
        end
        
    end
    
end