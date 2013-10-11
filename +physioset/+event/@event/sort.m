function y = sort(x, varargin)


[~, idx] = sort(get_sample(x), varargin{:});
y = x(idx);

end