function obj = reorder(obj, newOrder)

if isempty(obj.FeatVals), return; end


obj.FeatVals = obj.FeatVals(newOrder, :);
obj.Selected = obj.Selected(newOrder);


end