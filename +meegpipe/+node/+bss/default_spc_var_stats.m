function obj = default_spc_var_stats()

obj = mjava.hash;

obj('mean var %') = @(icVar, rawVar) floor(100*mean(icVar./rawVar));
obj('25% var %') = @(icVar, rawVar) floor(100*prctile(icVar./rawVar, 25));
obj('75% var %') = @(icVar, rawVar) floor(100*prctile(icVar./rawVar, 75));
obj('max var %') = @(icVar, rawVar) floor(100*max(icVar./rawVar));

end