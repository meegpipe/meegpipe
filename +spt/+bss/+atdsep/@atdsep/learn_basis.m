function [Wo, Ao, selection, obj] = learn_basis(obj, data, ev, varargin)

% Documentation: class_atdsep.txt
% Description: Learns aTDSEP basis functions


import pset.event.class_selector;
import spt.bss.atdsep.*;
import misc.eta;
import misc.nearest2;

if nargin < 3 || isempty(ev), ev = []; end

tau = get_config(obj, 'Lag');
lambda = get_config(obj, 'Lambda');

if isa(tau, 'function_handle'),
    tau = tau(data, ev, varargin{:});
end

if numel(tau) < 1,
    error('At least one lag needs to be specified!');
end

X = data(:,:);
n = size(X, 1);

% Clear static variables in cor2
clear +spt/+bss/+atdsep/cor2;

m = size(X,2);
X = [X zeros(size(X,1), max(tau)+1)];


verbose = is_verbose(obj);
if verbose,
    tinit = tic;
  
    clear +misc/eta;
end

jacobiTh = get_config(obj, 'JacobiTh');

if isempty(jacobiTh),
    jacobiTh = 0.00001;
end


%Wo = nan(n, n, numel(init)-1);
Wo = nan(n, n, m);
Ao = nan(size(Wo));

Qprev = eye(n);
Wprev = eye(n);
Aprev = eye(n);

winShift = get_config(obj, 'WindowShift');

% First 50 windows are used for the initial estimate
init = [1 50:winShift:m];

if init(end) < m
    init = [init m];
end

for j = 1:(numel(init)-1)
    
    sampleIdx = init(j):max(init(j)+max(tau), init(j+1));

    % whitening  
    Sigma       =  cor2(X(:,sampleIdx)',0,lambda);
    Sigma       = (Sigma+Sigma')/2;
    [U,D] 		= eig(Sigma);
    [puiss,k]	= sort(diag(D));
    puiss       = abs(puiss);
    rangeW		= 1:n;
    scales		= sqrt(puiss(rangeW));
    W           = diag(1./scales)  * U(1:n,k(rangeW))';
    
    if any(any(isnan(W(:)))) || any(any(isinf(W(:)))) || norm(W) > 1e6,
        W = Wprev;
    end
 
    Xj          = Qprev'*W*X(:,sampleIdx);   
    
    % compute correlation matrices
    N = length(tau);
    M = zeros(n, n*numel(tau));
    
    for i=1:N,
        
        Sigma = cor2(Xj',tau(i), lambda);   
        M(:, (i-1)*n+1:i*n) = (Sigma+Sigma')/2;
        
    end
    
    % joint diagonalization
    Q = jdiag(M, jacobiTh);
   
    if any(any(isnan(Q(:)))) || any(any(isinf(Q(:)))),
        Q = Qprev;
    else
        Qprev = Q;
    end
    
    thisWo = Q'*Qprev'*W;
    
    % Ensure the ordering/scaling is consistent with previous estimates
    [~, P] = nearest2(thisWo*Aprev, eye(n));
    thisWo = P*thisWo;
 
    if j > 500 && rcond(thisWo*pinv(Wprev)) < eps,
        thisWo = Wprev;
    else
        Wprev = thisWo;
    end
    
    Wo(:,:, init(j)) = thisWo;

    Ao(:,:, init(j)) = pinv(Wo(:,:,init(j)));
    
    Aprev = Ao(:,:, init(j));
    
    if verbose,
        eta(tinit, numel(init)-1, j);
    end
    
end

% Interpolate for every sample
t = 1:m;
tI = setdiff(t, [1:init(2)-1 init(2:end-1)]);
thisI = nan(1, m);
for i = 1:n
    for j = 1:n
        
        this = squeeze(Wo(i,j,init(1:end-1)));
        
        thisI(1:init(2)-1) = this(1);
        thisI(init(2:end-1)) = this(2:end);
        pp = interp1(init(2:end-1), this(2:end), ...
            'spline', 'pp');
        thisI(tI) = ppval(pp, tI);
      
        Wo(i,j,:) = thisI; 
        
        % Interpolate the inverse projection matrices as well
        this = squeeze(Ao(i,j,init(1:end-1)));
        
        thisI(1:init(2)-1) = this(1);
        thisI(init(2:end-1)) = this(2:end);
        pp = interp1(init(2:end-1), this(2:end), ...
            'spline', 'pp');
        thisI(tI) = ppval(pp, tI);
      
        Ao(i,j,:) = thisI; 
         
    end
end


selection = 1:size(W,1);


end