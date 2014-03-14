function [idx, featName] = extract_feature(obj, sptObj, ~, raw, rep, varargin)

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

myHead = obj.HeadModel;

if verbose,
    fprintf([verboseLabel 'Projecting sensors onto scalp surface ...']);
end
myHead = set_sensors(myHead, sensors(raw));
if verbose, fprintf('[done]\n\n'); end

if verbose,
    fprintf([verboseLabel 'Computing leadfield ...']);
end
evalc('myHead = make_source_surface(myHead, 5.5)');
evalc('myHead = make_leadfield(myHead);');
if verbose, fprintf('[done]\n\n'); end

M = bprojmat(sptObj);
featName = {'x', 'y', 'z', 'mx', 'my', 'mz'};
featVal  = nan(6, size(M, 2));

for i = 1:size(M, 2)
   
    myHead = inverse_solution(myHead, 'potentials', M(:,i), ...
        'method', obj.InverseSolver);
    [coords, m] = get_inverse_solution_centroid(myHead);
    featVal(:, i) = [coords(:);m(:)];
    
end

error('Not implemented yet!');

end