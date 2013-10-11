function [SigmaOut, SigmaMinusMinus] = compute_acov(obj, lag, idx, varargin)
% ACOV - Analytical zero-lag covariance based on VAR model coefficients
%
% [C, Cminus] = compute_acov(obj, lag, idx)
%
% where
%
% LAG is the covariance lag(s)
%
% C is the covariance matrix of the model observations at the specified
% lags. 
%
% CMINUS=C(m+1:end,m+1:end) where m=dim(obj)
%
% IDX the indices of the relevant data dimensions. If not provided, all
% data dimensions will be considered.
%
%
%
% See also: abstract_var

% Documentation: class_var_abstract_var.txt
% Description: Analytical covariance


if nargin < 3 || isempty(idx),
    idx = 1:var_dimensionality(obj);
end

if nargin < 2 || isempty(lag),
    lag = 0;
end

% Build matrix G
m           = dim(obj);
p           = order(obj);
varCoeffs   = coeffs(obj);
innCov      = icov(obj);
nCov        = ncov(obj);

% Account for the indices
cols = repmat(0:m:(p-1)*m, numel(idx), 1)+repmat(idx(:), 1, p);
varCoeffs = varCoeffs(idx, cols(:));
m = numel(idx);

pstar = max(max(lag)+1,p);
G = [varCoeffs zeros(m,m*max(0,(max(lag)+1-p)));zeros(m*(pstar-1), m*pstar)];
for i = 2:pstar,
    G((i-1)*m+1:i*m, (i-2)*m+1:(i-1)*m) = eye(m);
end

% Build matrix M
M = zeros(m*pstar, m*pstar);
M(1:m,1:m) = innCov(idx, idx);

% Covariance of the high-dimensional order-1 model
Sigma = reshape(pinv(eye((m*pstar)^2,(m*pstar)^2)-kron(G,G))*M(:), m*pstar, m*pstar);

SigmaOut = zeros(m, m*numel(lag));

for i = 1:numel(lag)
    colIndex = lag(i)*m+1:(lag(i)+1)*m;
    SigmaOut(:, (i-1)*m+1:i*m) = Sigma(1:m, colIndex);
    if lag(i) == 0 && ~isempty(nCov),
        SigmaOut(:, 1:m) = SigmaOut(:, 1:m) + nCov(idx, idx);
    end
end
if numel(lag)>1,
    SigmaMinusMinus = Sigma(m+1:end, m+1:end);
else
    SigmaMinusMinus = Sigma;
end
if ~isempty(nCov),
    for i = 1:numel(lag)
        index = (i-1)*m+1:i*m;
        SigmaMinusMinus(index, index) = SigmaMinusMinus(index, index)+nCov(idx, idx);
    end
end

end