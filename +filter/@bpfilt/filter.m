function [x, obj] = filter(obj, x, varargin)
% FILTER - Digital filtering
%
% x = filter(obj, x)
%
% where
%
% OBJ is a filter.bpfilt object
%
% X is the KxM data matrix to be filtered. X can be a numeric data matrix
% or an object of any class with suitably overloaded subsref and subsasgn
% operators.
%
%
% See also: filtfilt

import misc.eta;

verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

if isempty(obj.LpFilter) && isempty(obj.HpFilter),
   return; 
end

if verbose,
    if isa(x, 'physioset.physioset'),
        fprintf([verboseLabel 'BP-filtering %s...'], get_name(x));
    else
        fprintf([verboseLabel 'BP-filtering...']);
    end
end

if verbose,
    tinit = tic;
    by100 = floor(size(x,1)/100);
    clear +misc/eta;
end

mdFiltObj = mdfilt(obj);
if ~obj.PersistentMemory,
    grpDelay = floor(max(grpdelay(mdFiltObj)));
    grpDelay = min(grpDelay, size(x, 2));
end

for i = 1:size(x,1),
    if (isa(obj, 'physioset.physioset') && obj.BadChan(i)),
        continue;
    end
   
    if obj.PersistentMemory,
        x(i, :) = filter(mdFiltObj, x(i,:));
    else        
        tmp = filter(mdFiltObj, [x(i, grpDelay:-1:1) x(i,:) x(i, end:-1:end-grpDelay+1)]);
        x(i, :) = tmp(grpDelay+1:end-grpDelay);
    end
    if verbose && ~mod(i, by100),
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
end
if verbose,
    fprintf('\n\n');
end


end