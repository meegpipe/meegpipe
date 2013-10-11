function [W, A, selection, obj] = learn_basis(obj, data, ev, varargin)


import spt.bss.*; 
import physioset.event.class_selector;

if nargin < 3 || isempty(ev), ev = []; end

evClass = get_config(obj, 'EventClass');

tau = [];
if ~isempty(ev) && ~isempty(evClass),
     evSel = class_selector(evClass);
     ev = select(evSel, ev);
     if ~isempty(ev),
        sample = get_sample(ev);
        
        if numel(sample) > 10,
            tau = (median(sample)-mads(samples)):(median(sample)+mads(sample));
        else
            tau = median(sample);
        end
        
     end
end

if isempty(tau),
    tau = get_config(obj, 'Lag');
end

if numel(tau) < 1,
    error('At least one lag needs to be specified!');
end

X = data(:,:);
[n, T] = size(X);
% whitening & projection onto signal subspace
Sigma       = (X*X')/T;
Sigma       = (Sigma+Sigma')/2;
[U,D] 		= eig(Sigma);
[puiss,k]	= sort(diag(D));
rangeW		= 1:n; 
scales		= sqrt(puiss(rangeW)); 
W           = diag(1./scales)  * U(1:n,k(rangeW))';
X           = W*X;


% compute correlation matrices
N = length(tau);
M = zeros(n, n*numel(tau));
for i=1:N,
  Sigma = cor2(X',tau(i));
  Sigma = (Sigma+Sigma')/2;
  M(:, (i-1)*n+1:i*n) = Sigma;  
end  

% joint diagonalization
Q = jdiag(M,0.00000001);
% compute mixing matrix
W=Q'*W;
A = pinv(W);

selection = 1:size(W,1);


end