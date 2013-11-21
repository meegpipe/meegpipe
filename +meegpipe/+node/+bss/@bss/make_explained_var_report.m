function [statKeys, statVals] =  ...
    make_explained_var_report(obj, myBSS, data, rep, verbose, verboseLabel)

import plot2svg.plot2svg;
import inkscape.svg2png;
import misc.rnd_line_format;
import misc.unique_filename;
import mperl.file.spec.catfile;
import goo.globals;

visible = globals.get.VisibleFigures;
if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

[sensorArray, sensorIdx] = sensor_groups(sensors(data));
spcVarStats = get_config(obj, 'SPCVarStats');

% The full back-projection matrix (including non-selected components)
A = bprojmat(myBSS, true);

if ~isempty(spcVarStats)
    if verbose
        fprintf([verboseLabel, ...
            '\tGenerating backprojected variance report ...']);
    end
    
    statKeys = keys(spcVarStats);
    statVals = nan(size(A,2), numel(statKeys));
    
    print_title(rep, 'SPC''s backprojected variance', get_level(rep)+1);
    
    for i = 1:numel(sensorArray),
        
        subTitle = sprintf('Sensor set #%d (%d %s sensors)', ...
            i, nb_sensors(sensorArray{i}), class(sensorArray{i}));
        print_title(rep, subTitle, get_level(rep)+2);
        
        select(data, sensorIdx{i});
        rawVar = var(data, [], 2);
        for j = 1:size(A,2)
            for k = 1:numel(statKeys)
                fh = spcVarStats(statKeys{k});
                statVals(j, k) = fh(A(sensorIdx{i},j).^2, rawVar);
            end
        end
        restore_selection(data);
        
        figure('Visible', visibleStr);
        for k = 1:size(statVals, 2)
            plot(statVals(:,k), rnd_line_format(k), ...
                'LineWidth', 2);
            hold on;
        end
        legend(statKeys{:});
        xlabel('SPC index');
        set(gca, 'XTick', 1:size(A,2));
        
        % Print to a disk file and then to the report    
        rDir = get_rootpath(rep);
        fileName = unique_filename(catfile(rDir, 'bp_variance.svg'));
        evalc('plot2svg(fileName, gcf);');
        svg2png(fileName);
        close;
        myGallery = report.gallery.new;
        caption = ['Backprojected variance statistics (across all ' ...
            'channels) for each SPC'];
        
        add_figure(myGallery, fileName, caption);
        fprintf(rep, myGallery);
        
    end

    if verbose,
        fprintf('[done]\n\n');
    end
end

end