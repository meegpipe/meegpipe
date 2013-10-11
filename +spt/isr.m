function [y, y2] = isr(W, A)
% ISR - Interference to Signal Ratio for BSS estimates
%
% [y, y2] = isr(W, A)
%
% Where
%
% W is the estimated separating matrix, a K x M matrix
%
% A is the true mixing matrix, an M x K matrix
%
% Y is a KxK matrix with the ISR values for each pair of source estimates,
% in dB
%
% Y2 is a Kx1 vector with the total ISR for each source estimate, in dB
%
%
%
% ## Reference
% 
% [1] Tichavsky et al., 2008. A hybrid technique for blind separation of
%     non-Gaussian and time-correlated sources using a multicomponent
%     approach. IEEE Trans. Neural Networks 19 (3), 421-430.
%
%
% See also: spt.amari_index, spt.snr

% Documentation: pkg_spt.txt
% Description: Interferences to Signal Ratio for BSS estimates

import misc.nearest2;

W = nearest2(W, pinv(A));

G = W*A;

d = size(G,1);

y  = abs(((G-diag(diag(G))).^2)./((repmat(diag(G),1,d)).^2));
y2 = sum(y, 2);
y2 = 10*log10(y2);
y  = 10*log10(y);


end