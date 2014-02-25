function [x, obj] = filter(obj, x, varargin)
% FILTER - Digital filtering operation
%
% x = filter(obj, x)
%
% where
%
% OBJ is a filter.lpfilt object
%
% X is the KxM data matrix to be filtered. X can be a numeric data matrix
% or an object of any class with suitably overloaded subsref and subsasgn
% operators.
%
% See also: hpfilt, bpfilt


import misc.eta;

verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

if verbose,
    if isa(x, 'pset.mmappset'),
        name = get_name(x);
    else
        name = '';
    end
    fprintf([verboseLabel 'LP-filtering %s...'], name);
    tinit = tic;
    by25 = floor(size(x,1)/25);
    clear +misc/eta;
end

if ~obj.PersistentMemory,
    grpDelay = floor(max(grpdelay(obj.H)));
    grpDelay = min(grpDelay, size(x, 2));
end


for i = 1:size(x, 1)
    if (isa(obj, 'physioset.physioset') && obj.BadChan(i)),
        continue;
    end
    if obj.PersistentMemory,
        x(i, :) = filter(obj.H, x(i,:));
    else        
        tmp = filter(obj.H, [x(i, grpDelay:-1:1) x(i,:) x(i, end:-1:end-grpDelay+1)]);
        x(i, :) = tmp(grpDelay+1:end-grpDelay);
    end
    if verbose && ~mod(i, by25),
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
end
if verbose,
    fprintf('\n\n');
end

