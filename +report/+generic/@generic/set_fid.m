function set_fid(obj, fid)
% SET_FID - Associate report to open file handle
%
% set_fid(obj, fid)
%
% FID is a valid open file handle
%
% See also: get_fid, abstract_generator

% Description: Associate report to open file handle
% Documentation: class_abstract_generator.txt

obj.FID = fid;

if ~isempty(fid),
    set_filename(obj, fid.FileName);
end

end
