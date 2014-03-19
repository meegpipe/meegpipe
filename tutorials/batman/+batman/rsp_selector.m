classdef rsp_selector < physioset.event.selector
% RSP_SELECTOR - Selects PVT+RSP events
   
    properties
        StimType   = 'stm+';  % Type of the stimulus onset event
        RespType   = 'TRSP';  % Type of the response event
        TimingType = 'DIN4';  % Type of the event timing event associated to a StimType event
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
               
                [trspEv, trspEvIdx] = nn_all(stimEv, trspEv, ...
                    @(tx,ty) tx<ty);
 
                trspEvCount = 0;
                for i = 1:numel(stimEv)
                    stimEv(i) = set(stimEv(i), ...
                        'Sample', get(timingEv(i), 'Sample'), ...
                        'Time',   get(timingEv(i), 'Time'));
                    if isnan(trspEvIdx(i)), continue; end
                    trspEvCount = trspEvCount + 1;
                    stimEv(i) = set_meta(stimEv(i), get_meta(trspEv(trspEvCount)));
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
        function obj = rsp_selector(varargin)

            if nargin < 1, return; end
            
            import misc.process_arguments;
            
            opt.StimType   = 'stm+'; 
            opt.RespType   = 'TRSP';  
            opt.TimingType = 'DIN4';
            opt.StimCel    = [];
            opt.RespValue  = [];
            opt.Negated    = false;
            opt.DiscardMissingResp = true;
            [~, opt] = process_arguments(opt, varargin);

            fNames = fieldnames(opt);
            for i = 1:numel(fNames)
               obj.(fNames{i}) = opt.(fNames{i}); 
            end

        end

    end    

end