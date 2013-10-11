function obj = compute(obj,varObj,frequencies)
% COMPUTE Computes the directed transfer function (DTF)
%   
%   OBJ = COMPUTE(OBJ,MVAR) computes the DTF of the given MVAR object.
%

if nargin < 3 || isempty(frequencies),
    frequencies = linspace(0,1,10);
end

A = var_coefficients(varObj);

N = size(A,1);
p = size(A,2)/N;

A           = reshape(A,[N,N,p]);

% initialize variables
obj.Flow = zeros(N,N,length(frequencies));

for i = 1:length(frequencies)
    f = frequencies(i);
    % build A(f)
    Af = zeros(N,N);
    for r = 1:p
        Af = Af + squeeze(A(:,:,r))*exp(-1j*2*pi*f*r);
    end
    Hf = inv(eye(N,N)-Af);
    den = sum(((abs(Hf).^2)),2);
    obj.Flow(:,:,i) = Hf./repmat(sqrt(den),1,N);
end

obj.VAR = varObj;
obj.Freq = frequencies;