function C = icov(obj)

inn = innovations(obj);
C = cov(inn');

end