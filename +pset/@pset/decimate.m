function y = decimate(obj, factor, output_pset, varargin)

import pset.pset
import misc.process_arguments
import misc.eta

opt.verbose = is_verbose(obj);
[~, opt] = process_arguments(opt, varargin);


if nargin < 3,
    output_pset = [];
end

transposed_flag = false;
if obj.Transposed,
    obj.Transposed = false;
    transposed_flag = true;
end

if isempty(output_pset),
    y = pset.nan(size(obj,1), floor(size(obj,2)/factor));
    y.Writable = obj.Writable;
    y.Temporary = true;
else
    y = output_pset;
end

count = 0;
s.type = '()';
if opt.verbose,
    tinit = tic;
end
for i = 1:obj.NbChunks
    [~, data] = get_chunk(obj, i);
    data = data(:, 1:factor:end);
    nb_points = min(size(data, 2), size(y, 2)-count);
    s.subs = {1:size(data,1), count+1:count+nb_points};
    y = subsasgn(y, s, data(:, 1:nb_points));
    count = count + nb_points;
    if opt.verbose,
        eta(tinit, obj.NbChunks, i);
    end
end

if transposed_flag,
    obj.Transposed = true;    
    y.Transposed = true;
end


end