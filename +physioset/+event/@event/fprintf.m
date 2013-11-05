function count = fprintf(fid, ev, varargin)

import misc.process_arguments;

opt.SummaryOnly = false;
[~, opt] = process_arguments(opt, varargin);

count = 0;

if opt.SummaryOnly,
    % to be done
else
    for i = 1:numel(ev)
        
        str = event2str(ev(i));
        count = count + fprintf(fid, str);
        count = count + fprintf(fid, '\n');
        
    end
end


end