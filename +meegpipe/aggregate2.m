function [fName, aggrFiles] = aggregate2(fileList, regex, fName, ...
    fNameTrans, rowNames, includeFileName, verbose)
% AGGREGATE2 - New version of aggregate
%
% See: misc.md_help('meegpipe.aggregate2')

import mperl.file.find.finddepth_regex_match;
import mperl.file.spec.catdir;
import safefid.safefid;
import datahash.DataHash;
import misc.dlmread;
import mperl.join;

if nargin < 2 || isempty(regex),
    regex = '.+';
end

if nargin < 3 || isempty(fName),
    fName = '';
end

if nargin < 4 || isempty(fNameTrans),
    fNameTrans = '';
end

if nargin < 5 || isempty(rowNames),
    rowNames = true;
end

if nargin < 6 || isempty(includeFileName),
    includeFileName = true;
end

if nargin < 7 || isempty(verbose),
    verbose = true;
end

if isa(fileList{1}, 'physioset.physioset'),
    fileList = get_datafile(fileList{:});
end

%% Find all the files that are to be aggregated
aggrFiles = cell(numel(fileList)*5, 1);
origFiles = cell(numel(fileList)*5, 1);
count = 0;

for i = 1:numel(fileList)
   
    [path, name]  = fileparts(fileList{i});
    root = catdir(path, [name '.meegpipe']);
    thisFiles = finddepth_regex_match(root, regex, false, true, false);
    
    if isempty(thisFiles),
        continue;
    end
    
    aggrFiles(count+1:count+numel(thisFiles)) = thisFiles;
    origFiles(count+1:count+numel(thisFiles)) = ...
        repmat(fileList(i), numel(thisFiles), 1);
    count = count+numel(thisFiles);    
    
end

if count < 1,
    error('No files match the provided regex');
end

aggrFiles(count+1:end) = [];
aggrFiles = sort(aggrFiles);

%% Print the list of aggregated files in the header
if isempty(fName),
    fName = ['aggregate_' DataHash(aggrFiles) '.txt'];
end

fid = safefid(fName, 'w');

for i = 1:count
    fprintf(fid, '# %s\n', aggrFiles{i});
end

%% Do the aggregation
printedHeader = false;
for i = 1:count,
   thisFile = aggrFiles{i};
   if verbose,
       fprintf('(aggregate) Aggregating %s ...', thisFile);
   end
   
   thisFid = safefid(thisFile, 'r');
   count = 0;
   while 1
       tline = fgetl(thisFid);   
       count = count + 1;
       if ~ischar(tline), break; end
       if count > 1 || ~printedHeader
           fprintf(fid, '%s\n', tline);
           printedHeader = true;
       end
   end
   
   if verbose, fprintf('[done]\n\n'); end    
end



end