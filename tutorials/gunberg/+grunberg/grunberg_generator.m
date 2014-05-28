classdef grunberg_generator < physioset.event.generator & ...
        goo.abstract_setget
    
    properties
        NameRegex;
        Boundary;
        EventType;
    end
    
    methods (Static)
       % Default constructors
       function obj = default()
           [nameRegex, bndry, evType] = grunberg.epoch_definitions;
           obj = grunberg.grunberg_generator(...
               'NameRegex', nameRegex, ...
               'Boundary',  bndry, ...
               'EventType', evType);
       end
    end
    
    methods
        
        function evArray = generate(obj, data, varargin)
      
            evArray = [];
            for i = 1:numel(obj.NameRegex)
                if isempty(regexp(get_name(data), obj.NameRegex{i}, 'once')),
                    continue;
                end
                
                thisEv = physioset.event.event(1:size(obj.Boundary{i}, 1));
                for j = 1:size(obj.Boundary{i}, 1)
                    sampl = obj.Boundary{i}(j, 1)*data.SamplingRate;
                    sampl = min(size(data,2), max(1, sampl));
                    dur   = diff(obj.Boundary{i}(j,:))*data.SamplingRate;
                    dur   = max(1, min(dur, 1+size(data,2)-sampl));
                    thisEv(j).Sample = sampl;
                    thisEv(j).Duration = dur;
                    thisEv(j).Type = obj.EventType{i}{j};
                end
                
                evArray = [evArray thisEv];
              
            end
            
        end        
        
        % Constructor
        function obj = grunberg_generator(varargin)
            
            import misc.process_arguments;
            import misc.set_properties;
            
            opt.NameRegex = {};
            opt.Boundary  = {};
            opt.EventType = {};
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj = set_properties(obj, opt);
        end
    end
    
    
end