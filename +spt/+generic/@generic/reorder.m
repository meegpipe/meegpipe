function obj = reorder(obj, idx)

obj.W = obj.W(idx,:);
obj.A = obj.A(:, idx);
obj.Selected = obj.Selected(idx);

end