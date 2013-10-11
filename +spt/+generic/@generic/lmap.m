function obj = lmap(obj, W)

obj.W = W*obj.W;
obj.A = obj.A*pinv(W);

end