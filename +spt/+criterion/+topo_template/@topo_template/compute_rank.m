function rankValue = compute_rank(obj, sptObj, ~, ~, ~, ~, data, varargin)


import misc.eta;
import misc.unit_norm;

if nargin < 2 || isempty(sptObj) || ~isa(sptObj, 'spt.spt'),
    error('A spt.spt object is expected as second input argument');
end

% Candidate topographies
A = bprojmat(sptObj);

rankValue = zeros(1, size(A,2));

if isempty(A),    
    return;
end

% Reference (template) topography
ref = get_config(obj, 'Template');

if isa(ref, 'function_handle'),
    ref = ref(data);
end

if size(ref, 1) ~= size(A,1),
    error('spt:criterion:topo_template:NonMatchingDimensions', ...
        'The template and candidate topographies have different dimensions');
end

% Find location of power peak
ref = ref - repmat(mean(ref,2), 1, size(ref,2));
P   = sum(ref.^2);
[~, idx] = max(P);

% Normalize topographies
A   = unit_norm(A);
ref = unit_norm(ref(:, idx));

rankValue = abs(A'*ref);



end