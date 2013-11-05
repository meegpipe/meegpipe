function count = fprintf(fid, ev, varargin)

import misc.process_arguments;

opt.SummaryOnly = false;
[~, opt] = process_arguments(opt, varargin);

count = 0;

if opt.SummaryOnly,

    uTypes = unique(ev);
    count = count +  fprintf(fid, '%d events of %d type(s)\n\n', ...
        numel(ev), numel(uTypes));
    
    if numel(uTypes) < 20,
        count = count + fprintf(fid, '%-40s|%-20s\n', ...
            'Event Type', '# events');
        str = repmat('-', 1, 50);
        count = count + fprintf(fid, '%40s|%20s\n', str, str);
        for i = 1:numel(uTypes)
            nbEv = numel(select(ev, 'Type', uTypes{i}));
            
            count = count + ...
                fprintf(fid, '%40s|%20d\n', uTypes{i}, nbEv);
        end
        fprintf(fid, '\n\n');
    end
    
else
    for i = 1:numel(ev)
        
        str = event2str(ev(i));
        count = count + fprintf(fid, str);
        count = count + fprintf(fid, '\n');
        
    end
end


end