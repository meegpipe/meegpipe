function [data, dataNew] = process(obj, data, varargin)

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

dataNew = [];

if verbose,
    
    [~, fname] = fileparts(data.DataFile);
    fprintf([verboseLabel 'Generating events ...'], fname);

end

evGen = get_config(obj, 'EventGenerator');

evLogName = [get_name(data) '_events.log'];
rep = get_report(obj);
print_title(rep, 'Events generation report', get_level(rep) + 1);
print_paragraph(rep, 'List of generated events: [%s][evlog]', ...
    evLogName);
print_link(rep, ['../' evLogName], 'evlog');


if do_reporting(obj),
    rep = get_report(obj);
else
    rep = [];
end
evArray = generate(evGen, data, rep, varargin{:});

add_event(data, evArray);

if verbose, fprintf('[done]\n\n'); end


if verbose,
    fprintf([verboseLabel ...
        'Writing events properties to log file %s ...'], ...
        evLogName);
end

fid = get_log(obj, evLogName);
fprintf(fid, evArray);

if verbose, fprintf('[done]\n\n'); end



end