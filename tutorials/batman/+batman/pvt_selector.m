classdef pvt_selector < physioset.event.abstract_selector
    % PVT_SELECTOR - Selects the first PVT event within each PVT sub-block
    %
    % See also: batman
    
    properties
        
        % The minimum distance between two correlative PVT sub-blocks, in
        % samples
        MinBlockDistance  = 5*60*1000;
        
        % The types of the PVT stimulus event and of the associated
        % response event
        EventType = {'^stm\+$', '^DIN4$'}; 
        
        % If negated is set to true, then the complementary set of events
        % will be selected
        Negated   = false;
        
    end
    
    % Consistency checks
    % Having these is not required, but is generally a good idea
    methods
        
        function obj = set.MinBlockDistance(obj, value)
            
            import exceptions.*;

            if isempty(value),
                obj.MinBlockDistance = 5*60*1000;
                return;
            end
            
            if numel(value) ~= 1 || value < 0,
                throw(InvalidPropValue('MinBlockDistance', ...
                    'Must be a positive scalar'));
            end
            
            obj.MinBlockDistance = value;
            
        end
        
        function obj = set.EventType(obj, value)
            
            import exceptions.*;
            import misc.join;
            
            
            if ~iscell(value), value = {value}; end
            
            isString = cellfun(@(x) misc.isstring(x), value);
            
            if ~all(isString),
                throw(InvalidPropValue('EventType', ...
                    'Must be a cell array of strings'));
            end
            
            obj.EventType = value;
            
            
            if isempty(obj.Name),
                
                % Name is based on the types of selected events
                name = join('_', value);
                obj = set_name(obj, name);
                
            end
            
        end
        
        function obj = set.Negated(obj, value)
            import exceptions.*;
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Negated', ...
                    'Must be a logical scalar'));
            end
            obj.Negated = value;
            
        end
        
    end
    
    % selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        function [evArray, idx] = select(obj, evArray)
            
            selected = true(size(evArray));
            
            % Select only events of the right type
            if isempty(obj.EventType),
                
                thisSelected = true(size(selected));
                
            else
                
                thisSelected = false(size(selected));
                for i = 1:numel(obj.EventType),
                    regex = obj.EventType{i};
                    af = @(x) ~isempty(regexp(get(x, 'Type'), regex, 'once'));
                    
                    thisSelected = thisSelected | arrayfun(af, evArray);
                end
                
            end
            
            selected = selected & thisSelected;            
           
            % Distance between events            
            sampl = get_sample(evArray(selected));
            dist  = diff(sampl);
           
            thisSelected = [true;dist(:) > obj.MinBlockDistance];            
         
            idxSelected = find(selected);
            selected(idxSelected(~thisSelected)) = false;    
            
            % Remove all those events that do not have bunch of events
            % following them
            idxSel = find(selected);
            samplSelected = get_sample(evArray(selected));
            
            for i = 1:numel(samplSelected)
               
                % distance between this and all other PVT events
                dist = sampl - samplSelected(i);
                
                nbFollowing = numel(find(dist > 0 & dist < obj.MinBlockDistance));
                
                if nbFollowing < 40,
                    selected(idxSel(i)) = false;
                end
                
            end
            
            % Now remove all of those that are too close to each other
            [samplSelected, I] = sort(get_sample(evArray(selected)));
            idxSelected = find(selected);
            idxSelected = idxSelected(I);
            for i = 1:numel(samplSelected)
               if isnan(samplSelected(i)), continue; end
               samplSelected(samplSelected < ...
                   (samplSelected(i) + obj.MinBlockDistance) & ...
                   samplSelected > samplSelected(i)) = NaN;
            end
            selected(idxSelected(isnan(samplSelected))) = false;
 
            if obj.Negated,
                selected = ~selected;
            end
            
            evArray = evArray(selected);
            
            idx = find(selected);
        end
        
    end
    
    % Constructor
    methods
        
        function obj = pvt_selector(varargin)
            
            import misc.process_arguments;
            
            obj = obj@physioset.event.abstract_selector(varargin{:});
            
            if nargin < 1, return; end
            
            opt.MinBlockDistance = 5*60*1000;
            opt.EventType  = {'^stm\+$', '^DIN4$'};
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.MinBlockDistance = opt.MinBlockDistance;
            obj.EventType  = opt.EventType;
            
        end
        
    end
    
    
end