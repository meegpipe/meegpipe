function count = fprintf(fid, obj, varargin)
% FPRINTF - Print spatial transformation information to Remark report
%
% count = fprintf(fid, obj);
% count = fprintf(fid, obj, 'key', value, ...)
%
% Where
%
% FID is a file handle or a safefid.safefid object
%
% OBJ is a physioset object
%
%
% ## Accepted key/value pairs:
%
%       ParseDisp : (boolean).
%           Default: get_method_config(obj, 'fprintf', 'ParseDisp')
%           If set to true, a summary of the spt object properties will be
%           printed. This will be done by simply parsing the output
%           produced by method disp() of the spt class. 
%
%       SaveBinary: (boolean).
%           Default: get_method_config(obj, 'fprintf', 'SaveBinary')
%           If set to true, a binary copy of the spt object will be saved
%           and a link to it will be printed to the Remark report
%
% See also: physioset

import misc.process_arguments;
import misc.fid2fname;
import mperl.file.spec.*;
import misc.code2multiline;
import pset.globals;

origVerbose = goo.globals.get.Verbose;
goo.globals.set('Verbose', false);

opt.ParseDisp   = true;
opt.SaveBinary  = false;

cfg = get_method_config(obj, 'fprintf');
cfg = [cfg(:);varargin(:)];
[~, opt] = process_arguments(opt, cfg);

count = 0;
if opt.ParseDisp,
    
    myTable = parse_disp(obj);
    
    count = count + fprintf(fid, myTable);
    
end

if opt.SaveBinary,
    
    fName = rel2abs(fid2fname(fid));
    rPath = fileparts(fName);
    
    % Save binary data
    dataName    = get_name(obj);
    
    newDataFile = catfile(rPath, [dataName '.mat']);
    
    if ~exist(newDataFile, 'file'),
        sptObj = obj; %#ok<NASGU>
        save(newDataFile, 'sptObj');
    end
    
    count = count + ...
        fprintf(fid, '\n%-20s: [%s][%s]\n\n', ...
        'Binary BSS object', ...
        [dataName '.mat'], [dataName '-data']);
    
    count = count + ...
        fprintf(fid, '[%s]: %s\n', [dataName '-data'], ...
        [dataName '.mat']);
    
    count = count + ...
        fprintf(fid, '\n\nTo load to MATLAB''s workspace:\n\n');
    
    count = count + fprintf(fid, '[[Code]]:\n');
    
    code = sprintf('bss = load(''%s'', ''sptObj'')', newDataFile);
    code = code2multiline(code, [], char(9));
    count = count + fprintf(fid, '%s\n\n', code);
    
    count = count + fprintf(fid, ...
        '\n\nThen, to get the estimated mixing and separating matrices:\n\n');
    
    count = count + fprintf(fid, '\t%% The mixing (backprojection) matrix:\n');
    count = count + fprintf(fid, '\tA = bprojmat(bss.sptObj);\n\t\n');
    count = count + fprintf(fid, '\t%% The separating (projection) matrix:\n');
    count = count + fprintf(fid, '\tW = projmat(bss.sptObj);\n\n');

end

goo.globals.set('Verbose', origVerbose);

end