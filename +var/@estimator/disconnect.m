function obj = disconnect(obj)


tmp = obj;
tmp.Univariate = true;

obj = learn(tmp, observations(obj));

end