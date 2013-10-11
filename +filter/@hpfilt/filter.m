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
    by100 = floor(size(x,1)/100);
    clear +misc/eta;
end

for i = 1:size(x, 1)
    if isa(obj, 'physioset.physioset') && obj.BadChan(i),
        continue;
    end
    x(i, :) = filter(obj.H, x(i,:));
    if verbose && ~mod(i, by100)
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
end
if verbose,    
    fprintf('\n\n');
end
