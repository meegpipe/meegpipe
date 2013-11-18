function generate_win_report(rep, sensorsObj, bss, ics, idx, rej)

import mperl.file.spec.rel2abs;
import goo.globals;
import physioset.plotter.snapshots.snapshots;
import report.object.object;
import report.plotter.plotter;
import spt.plotter.topography.topography;
import report.gallery.gallery;
import physioset.plotter.psd.psd;

verbose      = globals.get.Verbose;
verboseLabel = globals.get.VerboseLabel;

% Deactivate verbose mode for any function call
globals.set('Verbose', false);

if verbose
    fprintf( [verboseLabel, 'Generating SPCs report...\n\n']);
end

% print message regarding the actual components that were selected.
if ~any(idx),
    msg = 'No components';
else
    msg = ['Component(s) __[', ...
        regexprep(num2str(find(idx(:)')), '\s+', ', ') ']__'];
end

warnMsg = ['Note that this ' ...
    ' selection may differ from the selection that the automatic ' ...
    ' criterion suggests, either because of the user having ' ...
    ' overriden the selection, or because property FixNbICs is' ...
    ' in effect.'];

if rej,
    print_paragraph(rep, [msg ...
        ' were __REJECTED__ in this analysis window. ' warnMsg]);
else
    print_paragraph(rep, [msg ...
        ' were __ACCEPTED__ in this analysis window. ' warnMsg]);
end

%% Binary file storing the ICs
print_title(rep, 'Spatial components'' activations', get_level(rep) + 1);

set_method_config(ics, 'fprintf', 'ParseDisp', false, 'SaveBinary', true);

fprintf(rep, ics);

%% The BSS object
print_title(rep, 'BSS decomposition', get_level(rep) + 1);

set_method_config(bss, 'fprintf', 'ParseDisp', false, 'SaveBinary', true);

fprintf(rep, bss);


%% Snapshots of all ICs
if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs snapshots...']);
end

snapshotPlotter = snapshots(...
    'MaxChannels',  Inf, ...
    'WinLength',    [10 25], ...
    'NbBadEpochs',  0, ...
    'NbGoodEpochs', 3);

snapshotRep = plotter(...
    'Plotter',  snapshotPlotter, ...
    'Title',    'Activations'' snapshots');

embed(snapshotRep, rep);

print_title(rep, 'SPCs snapshots', get_level(rep) + 1);

set_level(snapshotRep, get_level(rep) + 2);

generate(snapshotRep, ics);

if verbose, fprintf('[done]\n\n'); end

%% Topographies of all ICs
if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs topographies...']);
end

[sensorArray, sensorIdx] = sensor_groups(sensorsObj);

A = bprojmat(bss);

if rej,
    rejStr = ' (REJECTED)';
else
    rejStr = ' (ACCEPTED)';
end


for i = 1:numel(sensorArray),
    
    if numel(sensorIdx{i}) < 5,
        continue;
    end
    
    topoNames = num2cell((1:size(A,2))');
    
    topoNames = cellfun(@(x) ...
        ['SPC #' num2str(x) ' (sensor set ' num2str(i) ')'], topoNames, ...
        'UniformOutput', false);
    
    for k = 1:numel(topoNames)
        
        if ~idx(k), continue; end
        topoNames{k} = [topoNames{k} rejStr];
        
    end
    
    sensorClass = regexprep(class(sensorArray{i}), '^sensors\.', '');
    sensorClass = upper(sensorClass);
    
    if ~ismember(sensorClass, {'EEG', 'MEG'}),
        continue;
    end
    
    thisSensors = subset(sensorsObj, sensorIdx{i});
    
    if any(any(isnan(cartesian_coords(thisSensors)))),
        warning('bss_regr:MissingCoordinates', ...
            'Missing sensor coordinates: skipping topographies');
        continue;
    end
    
    
    repTitle = sprintf('%s topographies (channels %d-%d)', ...
        sensorClass, sensorIdx{i}(1), sensorIdx{i}(end));
    topoRep = plotter(...
        'Plotter',  topography, ...
        'Gallery',  gallery('NoLinks', true),  ...
        'Title',    repTitle);
    
    topoRep = embed(topoRep, rep);
    
    print_title(rep, 'SPCs topographies', get_level(rep) + 1);
    
    generate(topoRep, thisSensors, A(sensorIdx{i}, :), topoNames);
    
    if verbose, fprintf('.'); end
    
end
if verbose, fprintf('[done]\n\n'); end

%% PSDs of all ICs

if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs PSDs...']);
end

plotterObj = plotter.psd.psd(...
    'FrequencyRange',   [3 60], ...
    'Visible',          false, ...
    'LogData',          false);

psdPlotter = psd(...
    'MaxChannels',  size(ics, 1), ...
    'Channels',     num2cell(1:size(ics,1)), ...
    'WinLength',    30, ...
    'Plotter',      plotterObj); %#ok<FDEPR>

psdRep = plotter(...
    'Plotter',  psdPlotter, ...
    'Title',    'Activations PSDs');

print_title(rep, 'SPCs power spectral densities', get_level(rep) + 1);

generate(embed(psdRep, rep), ics);

if verbose, fprintf('\n\n'); end

%% Plot time-course and spatial topography of "noise" component
if any(idx)
    if verbose
        fprintf( [verboseLabel, '\tBackprojecting selected SPCs...']);
    end
    
    bss = deselect(bss, 'all');
    bss = select(bss, idx);
    select(ics, idx);
    data = physioset.physioset.from_pset(bproj(bss, ics), ...
        'Sensors', sensorsObj, 'SamplingRate', ics.SamplingRate);
    
    % Snapshots of top-variance channels
    print_title(rep, 'Backprojected SPCs', get_level(rep) + 1);
    
    dataVar = var(data, 0, 2);
      
    [~, chanIdx] = sort(dataVar, 'descend');
    
    snapshotPlotter = snapshots(...
        'MaxChannels',  Inf, ...
        'WinLength',    [10 25], ...
        'NbBadEpochs',  0, ...
        'NbGoodEpochs', 3);
    
    snapshotsRep = plotter(...
        'Plotter',  snapshotPlotter, ...
        'Title',    'Time-course at top-variance channels');
    
    print_title(rep, 'Time-course at top-variance channels', get_level(rep) + 2);
    
    chanIdx = sort(chanIdx(1:min(size(data,1), 5)), 'ascend');
    select(data, chanIdx);
    generate(embed(snapshotsRep, rep), data);
    
    % PSDs of top-variance channels
    plotterObj = plotter.psd.psd(...
        'FrequencyRange',   [3 60], ...
        'Visible',          false, ...
        'LogData',          false);
    
    psdPlotter = psd(...
        'MaxChannels',  numel(chanIdx), ...
        'Channels',     1:numel(chanIdx), ...
        'WinLength',    30, ...
        'Plotter',      plotterObj); %#ok<FDEPR>
    
    psdRep = plotter(...
        'Plotter',  psdPlotter, ...
        'Title',    'PSD across top-variance channels');
    
    print_title(rep, 'PSD across top-variance channels', get_level(rep) + 2);
    
    generate(embed(psdRep, rep), data);
    
    
    % Power topograhy for the selected components
    [sensorArray, sensorIdx] = sensor_groups(sensorsObj);
    
    for i = 1:numel(sensorArray),
        
        if numel(sensorIdx{i}) < 5,
            continue;
        end
        
        
        sensorClass = regexprep(class(sensorArray{i}), '^sensors\.', '');
        sensorClass = upper(sensorClass);
        
        if ~ismember(sensorClass, {'EEG', 'MEG'}),
            continue;
        end
        
        thisSensors = subset(sensorsObj, sensorIdx{i});
        
        if any(any(isnan(cartesian_coords(thisSensors)))),
            warning('bss_regr:MissingCoordinates', ...
                'Missing sensor coordinates: skipping topographies');
            continue;
        end
        
        repTitle = sprintf('%s power topographies (channels %d-%d)', ...
            sensorClass, sensorIdx{i}(1), sensorIdx{i}(end));
        topoRep = plotter(...
            'Plotter',  topography, ...
            'Gallery',  gallery('NoLinks', true),  ...
            'Title',    repTitle);
        
        topoRep = embed(topoRep, rep);
        
        print_title(rep, 'Power topography and average SPC topography', ...
            get_level(rep) + 2);
        
        topoName = {...
            'Power topography of selected SPCs', ...
            'Power-weighted average SPC topography', ...
            };
        
        topoVals = [dataVar(sensorIdx{i}), sum(A(sensorIdx{i}, idx), 2)];
        generate(topoRep, thisSensors, topoVals, topoName);
        
        if verbose, fprintf('.'); end
        
    end
    
    if verbose, fprintf('\n\n'); end
end

%% Return globals to their original state
globals.set('Verbose', verbose);

end