function [coord, m] = get_inverse_solution_centroid(obj)


[~, idx] = max((obj.InverseSolution.strength));

coord = obj.SourceSpace.pnt(idx,:);
m     = obj.InverseSolution.momentum(idx,:);
m = m/1e3;

end