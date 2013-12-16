function obj = set_innovations(obj, inn)

obj.Innovations = inn;

inn = transpose(inn);
obj.InnCov = cov(inn);

% Necessary if inn is a pset.mmappset. Otherwise harmless
transpose(inn);

end