function [data, dataNew] = process(obj, data, varargin)


import goo.globals;
import misc.eta;
import meegpipe.node.tfilter.tfilter;

dataNew = [];

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

%% Configuration options
chopSel         = get_config(obj, 'ChopSelector');
filtObj         = get_config(obj, 'Filter');
retRes          = get_config(obj, 'ReturnResiduals');
nbChannelsRep   = get_config(obj, 'NbChannelsReport');
epochDurRep     = get_config(obj, 'EpochDurReport');
showDiffRep     = get_config(obj, 'ShowDiffReport');
pca             = get_config(obj, 'PCA');

if isa(filtObj, 'function_handle'),
    filtObj = filtObj(data.SamplingRate);
end

%% Find chop boundaries
if ~isempty(chopSel),
    chopEvents = select(chopSel, get_event(data));
    if ~isempty(chopEvents),
        evSample = get(chopEvents, 'Sample');
        evDur    = get(chopEvents, 'Duration');
    end
else
    evSample = 1;
    evDur    = size(data,2);
end

tinit = tic;
if verbose,
    clear +misc/eta.m;
end

%% Select a representative set of channels for the report
if do_reporting(obj)
    
    channelSel = ceil(linspace(1, size(data,1), nbChannelsRep));
    channelSel = unique(channelSel);
    
    rep = get_report(obj);
    print_title(rep, 'Data processing report', get_level(rep) + 1);
end

%% Filter each segment separately
for segItr = 1:numel(evSample)
    
    if verbose && numel(evSample) > 1,
        
        fprintf( [verboseLabel ...
            '%s filtering for epoch %d/%d...\n\n'], ...
            get_name(filtObj), segItr, numel(evSample));
        origVerboseLabel = globals.get.VerboseLabel;
        globals.set('VerboseLabel', ['\t' origVerboseLabel]);
        
    end
    
    first = evSample(segItr);
    last  = min(evSample(segItr)+evDur(segItr)-1, size(data,2));
  
    
    filtObj = set_verbose(filtObj, false);
   
    if do_reporting(obj)
        thisRep = childof(report.generic.generic, rep);
        % Set the title of this (sub-)report
        if numel(evSample) > 1,
            % Multiple chops
            title  =  sprintf('Window %d/%d: %4.1f-%4.1f secs', ...
                segItr, ...
                numel(evSample), ...
                get_sampling_time(data, first), ... % Time of first sample
                get_sampling_time(data, last)...    % Time of last sample
                );
        else
            % All data at once
            title = 'Filtering report';
        end
        set_title(thisRep, title);
        initialize(thisRep);
        print_link2report(rep, thisRep);
        
        % Different galleries for different chop/epochs
        galleryObj = [];
    end
    
    %% Project to PCS, if required
    select(data, 1:size(data,1), first:last);
    if ~isempty(pca),
        if verbose,
            fprintf([verboseLabel 'PCA decomposition...\n\n']);
        end
        pca = learn(pca, data);
        pcs = proj(pca, data);
    else
        pcs = copy(data);
    end
    restore_selection(data);
    
    %% Filter every principal component
    if verbose,
        if isempty(pca),
            pcsStr = 'channel(s)';
        else
            pcsStr = 'principal component(s)';
        end
        fprintf([verboseLabel 'Filtering %d %s with %s filter...'], ...
            size(pcs,1), pcsStr, class(filtObj));
    end
      
    tinit2 = tic;
    
    for i = 1:size(pcs,1)
        
        thisData = pcs(i, :);
        
        pcs(i, :) = filtfilt(filtObj, thisData);
        
        if verbose,
            eta(tinit2, size(pcs,1), i, 'remaintime', true);
        end
        
    end
    if verbose,
        clear +misc/eta;
        fprintf('\n\n');
    end
    
    %% Filter the actual data channels
    if ~isempty(pca),
        % the bproj method displays status messages so no need here
        pcs = bproj(pca, pcs);
    end
    
    if verbose,
        fprintf([verboseLabel 'Updating data values in %d channels...'], ...
            size(data,1));
    end
    tinit2 = tic;
    for i = 1:size(data,1)
        
        thisData = data(i, first:last);
        filtData = pcs(i, :);
        
        if do_reporting(obj) && ismember(i, channelSel),
            % Select a subset of data for the report
            sr = data.SamplingRate;
            epochDur = floor(epochDurRep*sr);
            if epochDur >= evDur(segItr),
                firstRepSampl = 1;
                lastRepSampl  = evDur(segItr);
            else
                firstRepSampl = randi(evDur(segItr)-epochDur);
                lastRepSampl  = firstRepSampl + epochDur - 1;
            end
            
            % Get the being/end time for the reported epoch
            samplRange = first:last;
            samplTime = get_sampling_time(data, ...
                samplRange(firstRepSampl:lastRepSampl));
            
            attach_figure(obj);
            galleryObj = tfilter.generate_filt_plot(thisRep, ...
                i, ...
                thisData(firstRepSampl:lastRepSampl), ...
                filtData(firstRepSampl:lastRepSampl), ...
                samplTime, ...
                galleryObj, ...
                showDiffRep ...
                );
        end
        
        if retRes,
            thisData = thisData - filtData;
        else
            thisData = filtData;
        end
        
        data(i,first:last) = thisData;
        
        if verbose,
            eta(tinit2, size(pcs,1), i, 'remaintime', true);
        end
        
    end
    if verbose, fprintf('\n\n'); end
    
    if do_reporting(obj)
        fprintf(thisRep, galleryObj);
    end
    
    
    if verbose && numel(evSample) > 1,
        clear +misc/eta.m;
        verboseLabel = origVerboseLabel;
        globals.set('VerboseLabel', verboseLabel);
        
        fprintf( [verboseLabel, ...
            'done %s filtering epoch %d/%d...'], get_name(filtObj), ...
            segItr, numel(evSample));
        
        eta(tinit, numel(evSample), segItr, 'remaintime', true);
   
    end
    
end

if verbose,
    fprintf('\n\n');
    clear +misc/eta.m;
end


end