function rankValue = compute_rank(obj, ~, X,  ~, ~, ~, data, varargin)


import misc.eta;

if nargin < 7 || isempty(X) || isempty(data),
    error('At least 7 input arguments were expected');
end

rankValue = zeros(1, size(X,1));

if isempty(data),    
    return;
end

% Configuration options
dataSel = get_config(obj, 'Selector');
sumFunc = get_config(obj, 'SummaryFunc');

% Select reference signals
ref = select(dataSel, data);

if size(ref,2) > 0,   
    tmp = zeros(size(X,1), size(ref,1));
    for i = 1:size(X,1)
        for j = 1:size(ref,1),           
            tmp(i, j) = abs(xcorr(X(i,:), ref(j,:), 0 , 'coeff'));
        end
        rankValue(i) = sumFunc(tmp(i,:));
    end   
end


restore_selection(data);

end