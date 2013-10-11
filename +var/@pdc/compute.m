function obj = compute(obj, varObj, frequencies)
% COMPUTE Computes the Partial Directed Coherence (PDC)
%
%   OBJ = COMPUTE(OBJ,MVAR) computes the PDC of the given eegsim.MVAR
%   object MVAR.


if nargin < 3 || isempty(frequencies),
    frequencies = linspace(0,1,10);
end

A = var_coefficients(varObj);

N = size(A,1);
p = size(A,2)/N;

A           = reshape(A,[N,N,p]);
obj.Flow    = zeros(N,N,length(frequencies));

for i = 1:length(frequencies)
    f = frequencies(i);
    % build A(f)
    Af = zeros(N,N);
    for r = 1:p
        Af = Af + squeeze(A(:,:,r))*exp(-1j*2*pi*f*r);
    end
    Afh = (eye(N,N)-Af);
    den = zeros(1,N);
    for k = 1:N,
        den(1,k) = sqrt(ctranspose(Afh(:,k))*Afh(:,k));
    end
    obj.Flow(:,:,i) = Afh./repmat(den,N,1);
end

obj.VAR     = varObj;
obj.Freq    = frequencies;
