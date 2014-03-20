function [featVal, featName] = extract_feature(obj, sptObj, ~, raw, rep, varargin)

if nargin < 5, rep = []; end

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

myHead = obj.HeadModel;

M = bprojmat(sptObj);
if obj.CoordinatesOnly,
    featName = {'x', 'y', 'z'};
    featVal  = nan(3, size(M, 2));
else
    featName = {'x', 'y', 'z', 'mx', 'my', 'mz'};
    featVal  = nan(6, size(M, 2));
end

for i = 1:size(M, 2)
   
    myHead = inverse_solution(myHead, 'potentials', M(:,i), ...
        'method', obj.InverseSolver);
    [coords, m] = get_inverse_solution_centroid(myHead);
    if obj.CoordinatesOnly
        featVal(:, i) = coords(:); 
    else
        featVal(:, i) = [coords(:);m(:)];
    end
    
end

% Generate a report
if isempty(rep), return; end





end