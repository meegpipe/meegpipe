function obj = finalize(obj)
% FINALIZE - Finalizes a report
%
% obj = finalize(obj);
%
% This method closes the file handle associated with report object OBJ.
%
%
% See also: initialize, generic

% Documentation: class_report.txt
% Description: Finalize report

import misc.is_valid_fid;

fid = get_fid(obj);

if obj.CloseFID && ~isempty(fid) && is_valid_fid(fid),
    try
        fclose(fid);
    catch ME
        warning('abstract_generator:finalize:UnableToCloseFID', ...
            'I could not close file ''%s''', get_filename(obj));
        return;
    end
end

set_fid(obj, []);

end

