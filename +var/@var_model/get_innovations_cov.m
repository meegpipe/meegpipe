function C = get_innovations_cov(obj)

inn = get_innovations(obj);

inn = transpose(inn);
C = cov(inn);

% Necessary if inn if a pset.mmappset object. Otherwise, harmless.
tranpose(inn);

end