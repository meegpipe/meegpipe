function obj = rmap(obj, W)

obj.W = obj.W*W;
obj.A = pinv(W)*obj.A;

end