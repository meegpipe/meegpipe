function props = def_ev_translator(ev)
% def_ev_translator - Default translation of events into exp conditions
%
% See also: data_explorer

props.class = regexprep(class(ev), '.+\.([^.]+)$', '$1');
props.type  = get(ev, 'Type');

props.time = get(ev, 'Time');
if ~isempty(props.time),
    props.time = datestr(props.time);
end


end