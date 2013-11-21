function make_spcs_psd_report(obj, ics, rep, verbose, verboseLabel)

if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs PSDs...']);
end

psdRep = report.plotter.new(...
    'Plotter',  get_config(obj, 'PSDPlotter'), ...
    'Title',    'Activations PSDs');

print_title(rep, 'SPCs power spectral densities', get_level(rep) + 1);

generate(embed(psdRep, rep), ics);

if verbose, fprintf('\n\n'); end

end