function y = snr(W, A, S)
% SNR - Signal to Noise Ratio for BSS estimates
%
% y = snr(W, A, S)
%
% Where
%
% W is the estimated separating matrix, a K x M matrix
%
% A is the true mixing matrix, an M x K matrix
%
% S are the true source time-courses
%
% Y is a Kx1 vector with the signal to noise ratio for each source
% estimate, in dB
%
% See also: spt.isr, spt.amari_index

% Documentation: pkg_spt.txt
% Description: Signal to Noise Ratio for BSS estimates

import misc.nearest2;

W = nearest2(W, pinv(A));

Se = W*A*S;

Se = Se./repmat(sqrt(var(Se,[],2)), 1, size(Se,2));
S  = S./repmat(sqrt(var(S,[],2)), 1, size(S,2));

e = var(Se-S, [], 2);

y = -10*log10(e);

end