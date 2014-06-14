function [order, fs, rp, rs] = find_filter_order(fc, fs, rp, rs, maxOrder)

if nargin < 5, maxOrder = 30; end

order = ellipord(fc, fs, rp, rs);

while order > maxOrder && order > 2,
   fs = max(0.00001, 0.99*fs);
   rs = 0.99*rs; 
   rp = min(2, 1.001*rp);
   order = ellipord(fc, fs, rp, rs);
end


end