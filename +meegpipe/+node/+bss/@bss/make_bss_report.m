function rep = make_bss_report(obj, myBSS, ics, data)

import goo.globals;

verbose      = globals.get.Verbose;
verboseLabel = globals.get.VerboseLabel;

globals.set('Verbose', false);

parentRep = get_report(obj);

rep = childof(report.generic.new, parentRep);

%% Binary file storing the ICs
print_title(rep, 'Spatial components'' activations', get_level(rep) + 1);
set_method_config(ics, 'fprintf', 'ParseDisp', false, 'SaveBinary', true);
fprintf(rep, ics);

%% The BSS object
print_title(rep, 'BSS decomposition', get_level(rep) + 1);
set_method_config(bss, 'fprintf', 'ParseDisp', false, 'SaveBinary', true);
fprintf(rep, myBSS);

%% Snapshots of all ICs
if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs snapshots...']);
end

snapshotRep = plotter(...
    'Plotter',  get_config(obj, 'SnapshotPlotter'), ...
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

[sensorArray, sensorIdx] = sensor_groups(sensors(data));

% The full backprojection matrix
A = bprojmat(myBSS, true);

if rej,
    rejStr = ' (REJECTED)';
else
    rejStr = ' (ACCEPTED)';
end

selectedSPCs = component_selection(myBSS);

for i = 1:numel(sensorArray),  
    
    sensorClass = regexprep(class(sensorArray{i}), '^sensors\.', '');
    sensorClass = upper(sensorClass);
    
    if ~ismember(sensorClass, {'EEG', 'MEG'}) || numel(sensorIdx{i}) < 2,
        continue;
    end    

    topoNames = num2cell((1:size(A,2))');
    
    topoNames = cellfun(@(x) ...
        ['SPC #' num2str(x) ' (sensor set ' num2str(i) ')'], topoNames, ...
        'UniformOutput', false);
    
    for k = 1:numel(topoNames)        
        if ismember(k, selectedSPCs),
            topoNames{k} = [topoNames{k} rejStr];
        end        
    end    
   
    thisSensors = subset(sensorsObj, sensorIdx{i});
    
    if any(any(isnan(cartesian_coords(thisSensors)))),
        warning('bss:MissingCoordinates', ...
            'Missing sensor coordinates: skipping topographies');
        continue;
    end    
    
    repTitle = sprintf('%s topographies (channels %d-%d)', ...
        sensorClass, sensorIdx{i}(1), sensorIdx{i}(end));
    
    topoRep = plotter(...
        'Plotter',  get_config(obj, 'TopoPlotter'), ...
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

psdRep = plotter(...
    'Plotter',  get_config(obj, 'PSDPlotter'), ...
    'Title',    'Activations PSDs');

print_title(rep, 'SPCs power spectral densities', get_level(rep) + 1);

generate(embed(psdRep, rep), ics);

if verbose, fprintf('\n\n'); end


%% Plot time-course and spatial topography of "noise" component
if ~isempty(selectedSPCs)
    if verbose
        fprintf( [verboseLabel, '\tBackprojecting selected SPCs...']);
    end    
   
    selICs = subset(ics, selectedSPCs);    
    data = physioset.physioset.from_pset(bproj(myBSS, selICs));
 
    % Snapshots of top-variance channels
    print_title(rep, 'Backprojected SPCs', get_level(rep) + 1);
    
    dataVar = var(data, 0, 2);
      
    [~, chanIdx] = sort(dataVar, 'descend');
    
    snapshotPlotter = physioset.plotter.snapshots.new(...
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
    restore_selection(data);
    
    % PSDs of top-variance channels   
    psdRep = plotter(...
        'Plotter',  get_config(obj, 'PSDPlotter'), ...
        'Title',    'PSD across top-variance channels');
    
    print_title(rep, 'PSD across top-variance channels', get_level(rep) + 2);
    
    generate(embed(psdRep, rep), data);    
    
    % Power topograhy for the selected components
    [sensorArray, sensorIdx] = sensor_groups(sensors(data));
    
    for i = 1:numel(sensorArray),
        
        if numel(sensorIdx{i}) < 2,
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
            'Plotter',  get_config(obj, 'TopoPlotter'), ...
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

print_link2report(parentRep, rep);

globals.set('Verbose', verbose);

end