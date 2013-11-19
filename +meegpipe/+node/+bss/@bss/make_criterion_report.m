function count = make_criterion_report(obj, myCrit, icSel, isAutoSel)

rep = get_report(obj);

count = 0;
count = count + ...
    print_title(rep, 'Component selection criterion', get_level(rep) + 2);

count = count + fprintf(rep, myCrit);
count = count + fprintf(rep, '\n\n');

if ~any(icSel),
    msg = 'No components';
else
    msg = ['Component(s) __[', ...
        regexprep(num2str(icSel(:)'), ...
        '\s+', ', ') ']__'];
end

if ~isAutoSel
    warnMsg = 'This is a user-defined selection.';
else
    warnMsg = [];
end

if get_config(obj, 'Reject'),
    count = count + print_paragraph(rep, [msg ...
        ' were __REJECTED__ in this analysis window. ' warnMsg]);
else
    count = count + print_paragraph(rep, [msg ...
        ' were __ACCEPTED__ in this analysis window. ' warnMsg]);
end

end