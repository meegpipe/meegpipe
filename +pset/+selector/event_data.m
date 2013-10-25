classdef event_data < pset.selector.abstract_selector & goo.hashable
    % EVENT_DATA - Selects data epochs using events
    %
    % NOTE: This selector is obsolete and will be removed in future
    % versions. Use the event_selector selector instead.
    %
    % ## Usage synopsis:
    %
    % ````matlab
    % import pset.*;
    %
    % % Create sample physioset
    % X = randn(10,1000);
    % data = import(pset.import.matrix, X);
    %
    % % Add some arbitrary events
    % ev = event.std.qrs(100:100:1000, 'Duration', 10, 'Type', 'myType');
    % add_event(data, ev);
    % ev = event.std.qrs(1:10:100, 'Type', 'notMyType');
    % add_event(data, ev);
    %
    % % Select only myType epochs of class qrs
    % myEvent = event.std.qrs(1, 'Type', 'myType');
    % dataSel = selector.event_data(myEvent);
    % select(dataSel, data);
    % ````
    %
    % See also: selector
    
    
    %% IMPLEMENTATION
    
    properties (SetAccess = private, GetAccess = private)
        
        Negated             = false;
        Event               = [];
        Offset              = [];
        Duration            = [];
        
    end
    
    methods
        
        function obj = set.Event(obj, value)
            
            import exceptions.*
            
            if isempty(value),
                obj.Event = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'physioset.event.event'),
                throw(InvalidPropValue('Event', ...
                    'Must be an event object'));
            end
            
            obj.Event = value;
            
        end
        
        
        
    end
    
    
    %% PUBLIC INTERFACE ....................................................
    
    % goo.hashable
    methods
       
        function code = get_hash_code(obj)
            import datahash.DataHash;
            objStr = struct(obj);
            if ~isempty(obj.Event),
                objStr.Event = get_hash_code(obj.Event);
            end
            code = DataHash(objStr);            
        end
        
    end
    
    % pset.selector.selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = true;
            
        end
        
        function data = select(obj, data, remember)
            
            if nargin < 3 || isempty(remember),
                remember = true;
            end
            
            ev = get_event(data);
            
            if isempty(ev), return; end
            if isempty(obj.Event), return; end
            
            ev = ev(ev == obj.Event);
            
            if isempty(ev), return; end
            
            ev  = sort(ev);
            pos = get_sample(ev);
            
            if isempty(obj.Duration),
                dur = get_duration(ev);
            else
                dur = ceil(obj.Duration*data.SamplingRate);
                dur = repmat(dur, 1, numel(ev));
            end
            if isempty(obj.Offset),
                off = get_offset(ev);
            else
                off = ceil(obj.Offset*data.SamplingRate);
                off = repmat(off, 1, numel(ev));
            end
            
            selected = false(1, size(data,2));
            
            for i = 1:numel(pos)
                
                idx = pos(i) + off(i) + (0:dur(i)-1);
                
                if all(idx > size(data,2)),
                    break;
                end
                
                selected(idx(idx<=size(data,2))) = true;
                
            end
            
            select(data, [], find(selected), remember);
            
        end
        
    end
    
    % Public methods declared and defined here
    
    methods
        
        function disp(obj)
            
            import goo.disp_class_info;
            import misc.dimtype_str;
            
            disp_class_info(obj);
            
            if obj.Negated,
                fprintf('%20s : yes\n', 'Negated');
            else
                fprintf('%20s : no\n', 'Negated');
            end
            fprintf('%20s : [%s]\n', 'Event', ...
                dimtype_str(obj.Event, usejava('Desktop')));
            
            if ~isempty(obj.Duration),
                fprintf('%20s : %d\n', 'Duration', obj.Duration);
            end
            
            if ~isempty(obj.Offset),
                fprintf('%20s : %d\n', 'Offset', obj.Offset);
            end
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = event_data(ev, varargin)
            
            import misc.process_arguments;
            
            warning('event_data:Obsolete', ...
                'This selector is obsolete. Use event_selector instead');
            
            
            obj = obj@pset.selector.abstract_selector(varargin{:});
            
            if nargin < 1, return; end
            
            opt.Offset      = [];
            opt.Duration    = [];
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Offset      = opt.Offset;
            obj.Duration    = opt.Duration;
            
            obj.Event = ev;
            
        end
        
        
    end
    
    
    
end