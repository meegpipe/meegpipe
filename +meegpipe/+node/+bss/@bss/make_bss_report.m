function rep = make_bss_report(obj, myBSS, ics, data)

import goo.globals;

verbose      = globals.get.Verbose;
verboseLabel = globals.get.VerboseLabel;

globals.set('Verbose', false);

if verbose,
    fprintf([verboseLabel 'Generating BSS report ...\n\n']);
end
parentRep = get_report(obj);
rep = report.generic.new('Title', 'Blind Source Separation report');
rep = childof(rep, parentRep);

make_bss_object_report(obj, myBSS, ics, rep, verbose, verboseLabel);

make_spcs_snapshots_report(obj, ics, rep, verbose, verboseLabel);

[statKeys, statVals] = make_explained_var_report(obj, myBSS, data, rep, ...
    verbose, verboseLabel);

make_spcs_topography_report(obj, myBSS, data, rep, statKeys, statVals, ...
    verbose, verboseLabel);

make_spcs_psd_report(obj, ics, rep, verbose, verboseLabel);

make_backprojection_report(obj, myBSS, ics, rep, verbose, verboseLabel);

print_title(parentRep, 'Blind Source Separation', get_level(parentRep)+2);
print_link2report(parentRep, rep);
globals.set('Verbose', verbose);

end