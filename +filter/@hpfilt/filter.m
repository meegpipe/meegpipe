function [x, obj] = filter(obj, x, varargin)
% FILTER
%
% One-dimensional high-pass digital filtering
%
%
% x = filter(obj, x)
%
%
% where
%
% OBJ is a filter.hpfilt object
%
% X is the KxM data matrix to be filtered. X can be a numeric data matrix
% or an object of any class with suitably overloaded subsref and subsasgn
% operators.
%
%
% See also: hpfilt, lpfilt, bpfilt


import misc.eta;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

if verbose,
    if isa(x, 'physioset.physioset'),
        fprintf([verboseLabel 'HP-filtering %s...'], get_name(x));
    else
        fprintf([verboseLabel 'HP-filtering...']);
    end
end

if verbose,
    tinit = tic;
    by25 = floor(size(x,1)/25);
    clear +misc/eta;
end

if ~obj.PersistentMemory,
    grpDelay = floor(max(grpdelay(obj.H)));
    grpDelay = min(grpDelay, size(x, 2));
end

for i = 1:size(x, 1)
    if isa(obj, 'physioset.physioset') && obj.BadChan(i),
        continue;
    end
    if obj.PersistentMemory,
        x(i, :) = filter(obj.H, x(i,:));
    else        
        tmp = filter(obj.H, [x(i, grpDelay:-1:1) x(i,:) x(i, end:-1:end-grpDelay+1)]);
        x(i, :) = tmp(grpDelay+1:end-grpDelay);
    end
    if verbose && ~mod(i, by25)
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
end
if verbose,    
    fprintf('\n\n');
end
