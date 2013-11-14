function bool = has_selection(obj)


bool = ~isempty(dim_selection(obj)) || ~isempty(pnt_selection(obj));


end