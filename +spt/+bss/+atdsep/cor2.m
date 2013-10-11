function K=cor2(x, tau, lambda)
% COR2 - Online cross-correlation matrices
%
%

if nargin < 3, lambda = []; end

% The running estimate and the number of data samples
persistent numerator;
persistent N;

% if isvector(x),
%     x = x(:);  
% end
 
if nargin < 2, 
   tau=0;
end

m = size(x, 1);

tau = fix(abs(tau));

if tau>m 
   error('Choose tau smaller than Vector size');
end

L=x(1:m-tau,:);  
R=x(1+tau:m,:);

if isempty(numerator) || size(numerator,3)<=tau,
    numerator(:,:,tau+1) = L'*R;
else
    if ~isempty(lambda),
        numerator(:,:,tau+1) = lambda*numerator(:,:,tau+1);
    end
    numerator(:,:,tau+1) = numerator(:,:,tau+1) + L'*R;
end

if numel(N)<=tau,
    N(tau+1) = size(x,1)-tau;
else
    N(tau+1) = N(tau+1) + (size(x,1)-tau);
end

if lambda == 1,
    denominator = N(tau+1);
else
    denominator = (1-lambda^(N(tau+1)))/(1-lambda);
end

K = squeeze(numerator(:,:,tau+1)) / denominator; 

%K=(K+K')/2; 