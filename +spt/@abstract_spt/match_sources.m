function spf = match_sources(spf, A)

import misc.nearest2;

[~, P] = nearest2(projmat(spf)*A, pinv(A)*A);
spf.W = P*spf.W;
spf.A = spf.A*P';

selected = false(nb_component(spf), 1);
selected(spf.ComponentSelection) = true;
spf.ComponentSelection = find(P*selected);


end