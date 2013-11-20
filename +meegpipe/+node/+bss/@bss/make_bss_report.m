function rep = make_bss_report(obj, myBSS, ics, data)

import goo.globals;
import misc.rnd_line_format;
import misc.unique_filename;
import mperl.file.spec.catfile;
import plot2svg.plot2svg;
import inkscape.svg2png;

verbose      = globals.get.Verbose;
verboseLabel = globals.get.VerboseLabel;

visible = globals.get.VisibleFigures;
if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

globals.set('Verbose', false);

if verbose,
    fprintf([verboseLabel 'Generating BSS report ...\n\n']);
end

parentRep = get_report(obj);

rep = report.generic.new('Title', 'Blind Source Separation report');

rep = childof(rep, parentRep);

%% Binary file storing the ICs
print_title(rep, 'Spatial components'' activations', get_level(rep) + 1);
set_method_config(ics, 'fprintf', 'ParseDisp', false, 'SaveBinary', true);
fprintf(rep, ics);

%% The BSS object
print_title(rep, 'BSS decomposition', get_level(rep) + 1);
set_method_config(myBSS, 'fprintf', 'ParseDisp', false, 'SaveBinary', true);
fprintf(rep, myBSS);

%% Snapshots of all ICs
if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs snapshots...']);
end

snapshotRep = report.plotter.new(...
    'Plotter',  get_config(obj, 'SnapshotPlotter'), ...
    'Title',    'Activations'' snapshots');

embed(snapshotRep, rep);

print_title(rep, 'SPCs snapshots', get_level(rep) + 1);

set_level(snapshotRep, get_level(rep) + 2);

generate(snapshotRep, ics);

if verbose, fprintf('[done]\n\n'); end

%% SPCs explained variance

[sensorArray, sensorIdx] = sensor_groups(sensors(data));

spcVarStats = get_config(obj, 'SPCVarStats');
% The full back-projection matrix (including non-selected components)
A = bprojmat(myBSS, true);


if ~isempty(spcVarStats)
    if verbose
        fprintf( [verboseLabel, '\tGenerating backprojected variance report ...']);
    end
    
    varStatKeys = keys(spcVarStats);
    varStats = nan(size(A,2), numel(varStatKeys));
    
    print_title(rep, 'SPC''s backprojected variance', get_level(rep)+1);
    
    for i = 1:numel(sensorArray),
        
        subTitle = sprintf('Sensor set #%d (%d %s sensors)', ...
            i, nb_sensors(sensorArray{i}), class(sensorArray{i}));
        print_title(rep, subTitle, get_level(rep)+2);
        
        select(data, sensorIdx{i});
        rawVar = var(data, [], 2);
        for j = 1:size(A,2)
            for k = 1:numel(varStatKeys)
                fh = spcVarStats(varStatKeys{k});
                varStats(j, k) = fh(A(:,j).^2, rawVar);
            end
        end
        restore_selection(data);

        figure('Visible', visibleStr);
        for k = 1:size(varStats, 2)
            plot(varStats(:,k), rnd_line_format(k), ...
                'LineWidth', 2);
            hold on;
        end
        legend(varStatKeys{:});
        xlabel('SPC index');
        set(gca, 'XTick', 1:size(A,2));
        
        % Print to a disk file and then to the report
        
        rDir = get_rootpath(rep);
        fileName = unique_filename(catfile(rDir, 'bp_variance.svg'));
        evalc('plot2svg(fileName, gcf);');
        svg2png(fileName);
        close;
        myGallery = report.gallery.new;
        caption = 'Backprojected variance statistics (across all channels) for each SPC';

        add_figure(myGallery, fileName, caption);
        fprintf(rep, myGallery);
        
    end
   
    
    if verbose,
        fprintf('[done]\n\n');
    end
end

%% Topographies of all ICs
if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs topographies...']);
end

if get_config(obj, 'Reject'),
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
    
    for k = 1:numel(topoNames)
        topoNames{k} = sprintf('SPC #%d from sensor set %d', k, i);
        if ismember(k, selectedSPCs),
            topoNames{k} = [topoNames{k} rejStr];
        end
        if ~isempty(spcVarStats),
            topoNames{k} = [topoNames{k} '('];
            for m = 1:numel(varStatKeys),
                topoNames{k} = sprintf('%s%s=%d;', topoNames{k}, ...
                    varStatKeys{m}, round(varStats(k, m)));
            end
            topoNames{k} = [topoNames{k}(1:end-1) ')'];
        end
    end
    
    thisSensors = subset(sensors(data), sensorIdx{i});
    
    if any(any(isnan(cartesian_coords(thisSensors)))),
        warning('bss:MissingCoordinates', ...
            'Missing sensor coordinates: skipping topographies');
        continue;
    end
    
    repTitle = sprintf('%s topographies (channels %d-%d)', ...
        sensorClass, sensorIdx{i}(1), sensorIdx{i}(end));
    
    topoRep = report.plotter.new(...
        'Plotter',  get_config(obj, 'TopoPlotter'), ...
        'Gallery',  report.gallery.new('NoLinks', true),  ...
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

psdRep = report.plotter.new(...
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
    selICs = bproj(myBSS, selICs);
    
    % Snapshots of top-variance channels
    print_title(rep, 'Backprojected SPCs', get_level(rep) + 1);
    
    dataVar = var(selICs, 0, 2);
    
    [~, chanIdx] = sort(dataVar, 'descend');
    
    snapshotPlotter = physioset.plotter.snapshots.new(...
        'MaxChannels',  Inf, ...
        'WinLength',    [10 25], ...
        'NbBadEpochs',  0, ...
        'NbGoodEpochs', 3);
    
    snapshotsRep = report.plotter.new(...
        'Plotter',  snapshotPlotter, ...
        'Title',    'Time-course at top-variance channels');
    
    print_title(rep, 'Time-course at top-variance channels', get_level(rep) + 2);
    
    chanIdx = sort(chanIdx(1:min(size(selICs,1), 5)), 'ascend');
    select(selICs, chanIdx);
    generate(embed(snapshotsRep, rep), selICs);
    restore_selection(selICs);
    
    % PSDs of top-variance channels
    psdRep = report.plotter.new(...
        'Plotter',  get_config(obj, 'PSDPlotter'), ...
        'Title',    'PSD across top-variance channels');
    
    print_title(rep, 'PSD across top-variance channels', get_level(rep) + 2);
    
    generate(embed(psdRep, rep), selICs);
    
    % Power topograhy for the selected components
    [sensorArray, sensorIdx] = sensor_groups(sensors(selICs));
    
    for i = 1:numel(sensorArray),
        
        if numel(sensorIdx{i}) < 2,
            continue;
        end
        
        sensorClass = regexprep(class(sensorArray{i}), '^sensors\.', '');
        sensorClass = upper(sensorClass);
        
        if ~ismember(sensorClass, {'EEG', 'MEG'}),
            continue;
        end
        
        thisSensors = subset(sensors(selICs), sensorIdx{i});
        
        if any(any(isnan(cartesian_coords(thisSensors)))),
            warning('bss_regr:MissingCoordinates', ...
                'Missing sensor coordinates: skipping topographies');
            continue;
        end
        
        repTitle = sprintf('%s power topographies (channels %d-%d)', ...
            sensorClass, sensorIdx{i}(1), sensorIdx{i}(end));
        topoRep = report.plotter.new(...
            'Plotter',  get_config(obj, 'TopoPlotter'), ...
            'Gallery',  report.gallery.new('NoLinks', true),  ...
            'Title',    repTitle);
        
        topoRep = embed(topoRep, rep);
        
        print_title(rep, 'Power topography and average SPC topography', ...
            get_level(rep) + 2);
        
        topoName = {...
            'Power topography of selected SPCs', ...
            'Power-weighted average SPC topography', ...
            };
        
        topoVals = [dataVar(sensorIdx{i}), sum(A(sensorIdx{i}, selectedSPCs), 2)];
        generate(topoRep, thisSensors, topoVals, topoName);
        
        if verbose, fprintf('.'); end
        
    end
    
    if verbose, fprintf('\n\n'); end
end

print_title(parentRep, 'Blind Source Separation', get_level(parentRep)+2);

print_link2report(parentRep, rep);

globals.set('Verbose', verbose);

end