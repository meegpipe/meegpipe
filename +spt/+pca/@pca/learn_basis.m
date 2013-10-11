function [W, A, selection, obj] = learn_basis(obj, data, varargin)
% LEARN_BASIS - Learns PCA basis functions
%
%
% [W, A, selection] = learn_basis(obj, data)
%
% Where
%
% OBJ is a spt.pca object
%
% DATA is the data to which the PCA basis are to be fit. DATA can be a
% numeric data matrix or an object of any class that behaves as such, e.g.
% pset.pset and pset.physioset objects are allowed.
%
% W and A are, respectively, the forwards and backwards projection
% matrices. 
%
% SELECTION is a logical array that determines whether a spatial component
% is or not selected. 
%
%
% See also: spt.pca, spt

import spt.pca.pca;

obj.Samples = size(data,2);

%% PCA configuration
criterion   = lower(get_config(obj, 'Criterion'));
minSamples  = get_config(obj, 'MinSamples');
maxDimOut   = get_config(obj, 'MaxDimOut');
minDimOut   = get_config(obj, 'MinDimOut');
sphering    = get_config(obj, 'Sphering');
varTh       = get_config(obj, 'Var');
maxCond     = get_config(obj, 'MaxCond');

%% Learn the full basis

C = cov(data', 1);

if size(data,1) > size(data,2),
    data = data'; % necessary for pset.mmapset objects
end

if isa(minDimOut, 'function_handle'),
    minDimOut = minDimOut(size(data,1));
end
if isa(maxDimOut, 'function_handle'),
    maxDimOut = maxDimOut(size(data,1));
end

[V, D]              = eig(C);
Lambda              = diag(D);

[~, I]              = sort(diag(D), 'descend');
V                   = V(:,I);
tmp                 = diag(D);
D                   = tmp(I);
V(:, rank(C)+1:end) = [];
D(rank(C)+1:end)    = [];

if sphering,
    
    tmp = D.^(-.5);
else
    
    tmp = D.^(.5);
    
end

W = diag(tmp)*V';
A = pinv(W);

%% Model order selection
if ~ismember(criterion, {'rank', 'max'}),
    
    eval(['[kopt, crit] = pca.' criterion ...
        '(Lambda, obj.Samples);']);
    kopt = min(size(W,1), kopt); %#ok<NODEF>
    
else
    
    kopt = size(W,1);
    crit = [];
    
end

if minSamples > 0,
    
    maxDimSampleSize = ceil(sqrt(size(data,2)/minSamples));
else
    
    maxDimSampleSize = Inf;
    
end

kopt    = min([kopt, maxDimOut, maxDimSampleSize]);

% The abs() is needed to ensure that the maximum of cumVar is
% cumVar(end). Otherwise small (negative) numerical errors will cause
% troubles later
cumVar  = cumsum(abs(D));
cumVar  = cumVar/cumVar(end);
kMinVar = max(1, find(cumVar >= varTh(1), 1, 'first'));
tmp = find(cumVar > varTh(2), 1, 'first');
if isempty(tmp),
    tmp = size(data,2);
end

% Order to ensure certain condition number is not exceeded
kMaxCond = find(D(1)./D < maxCond, 1, 'last');

kMaxVar              = min(size(data,2), tmp);
kopt                 = max(kopt, kMinVar);
kopt                 = min(kopt, kMaxVar);
kopt                 = min(kopt, maxDimOut);
kopt                 = min(kopt, kMaxCond);

if minDimOut < 1,
    % it is a percentage
    minDimOut        = ceil(minDimOut*size(data,1));
end

kopt                 = max(kopt, minDimOut);

selection = 1:kopt;

% Set object properties
obj.CriterionValues = crit;
obj.Eigenvectors    = V;
obj.Eigenvalues     = Lambda;
obj.DimOpt          = kopt;


end