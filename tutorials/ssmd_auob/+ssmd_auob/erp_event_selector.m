classdef erp_event_selector < physioset.event.selector
    % ERP_EVENT_SELECTOR - Selects ERP events
    %
    % See: <a href="matlab:misc.md_help('ssmd_auob.event_selector')">misc.md_help(''ssmd_auob.event_selector'')</a>
    
   
    properties
        StimType   = 'stm+';  % Type of the stimulus onset event
        RespType   = 'RESP';  % Type of the response event
        TimingType = 'DIN ';  % Type of the event timing event associated to a StimType event
        StimCel    = []; 
        RespValue  = [];        
        Negated    = false;
        DiscardMissingResp = true;
    end

    methods

        function [evArray, idx] = select(obj, evArray)            

            [stimEv, stimIdx] = select(evArray, 'Type', obj.StimType);
            
            % Select only those stimuli of the correct cel
            if ~isempty(obj.StimCel),
                isSelected = arrayfun(...
                    @(x) get_meta(x, 'cel') == obj.StimCel, ...
                    stimEv);
                stimEv(~isSelected)  = [];
                stimIdx(~isSelected) = [];
            end
            
            
            if ~isempty(obj.TimingType),
          
                % Set the tmings of each stimEv according to the nearest
                % timing event
                timingEv = select(evArray, 'Type', obj.TimingType);
                timingEv = nn_all(stimEv, timingEv);
           
                % And add the TRSP info: response time and trial #
                trspEv = select(evArray, 'Type', 'TRSP');
                if ~isempty(obj.StimCel),
                    isSelected = arrayfun(...
                        @(x) get_meta(x, 'cel') == obj.StimCel, ...
                        trspEv);
                    trspEv(~isSelected)  = [];                    
                end
                trspEv = nn_all(stimEv, trspEv, ...
                    @(tx,ty) tx<ty);
               
                for i = 1:numel(stimEv)
                    stimEv(i) = set(stimEv(i), ...
                        'Sample', get(timingEv(i), 'Sample'), ...
                        'Time',   get(timingEv(i), 'Time'));
                    
                    stimEv(i) = set_meta(stimEv(i), get_meta(trspEv(i)));
                end
                
            end
            
            if isempty(stimEv),
                evArray = [];
                idx = [];
                return;
            end
           
            % Discard stim events that miss a response
            rtim = get_meta(stimEv, 'rtim');
            if iscell(rtim), rtim = cell2mat(rtim); end
            if ~obj.DiscardMissingResp,
                stimEv(rtim < eps) = [];
                stimIdx(rtim < eps) = [];
            end

            % Select only events that have a response with the desired value   
            if ~isempty(obj.RespValue),
               rsp = get_meta(stimEv, 'rsp');
               if iscell(rsp), rsp = cell2mat(rsp); end
               stimEv(rsp ~= obj.RespValue) = [];
               stimIdx(rsp ~= obj.RespValue) = [];
            end            
          
            if obj.Negated,
                idx = setdiff(1:numel(evArray), stimIdx);
            else
                idx = stimIdx;
            end
            evArray = stimEv;       

        end
        
        function obj = not(obj)
           
            obj.Negated = ~obj.Negated;
            
        end

        % Constructor
        function obj = erp_event_selector(varargin)

            if nargin < 1, return; end
            
            import misc.process_arguments;
            import misc.set_properties;
            
            opt.StimType   = 'stm+'; 
            opt.RespType   = 'RESP';  
            opt.TimingType = 'DIN ';
            opt.StimCel    = [];
            opt.RespValue  = [];
            opt.Negated    = false;
            opt.DiscardMissingResp = true;
            [~, opt] = process_arguments(opt, varargin);

            obj = set_properties(obj, opt);

        end

    end    

end