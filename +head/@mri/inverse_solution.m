function obj = inverse_solution(obj, varargin)
% INVERSE_SOLUTION - Compute inverse solution
%
% obj = inverse_solution(obj);
%
% obj = inverse_solution(obj, 'key', value, ...);
%
% Where
%
% OBJ is a head.mri object.
%
%
% See also: head.mri

import misc.process_arguments;

opt.lambda = 0;
opt.method = 'mne';
opt.time   = 1;

[~, opt] = process_arguments(opt, varargin);

switch lower(opt.method),
    case 'mne'
        A = obj.SourceDipolesLeadField;
        M = A'*pinv(A*A'+opt.lambda*eye(size(A,1)));
        
        potentials = scalp_potentials(obj, 'time', opt.time);
        
        strength = M*potentials;
        orientation = zeros(obj.NbSourceVoxels,3);
        momentum = zeros(obj.NbSourceVoxels,3);
        
    case 'dipfit'
        A = obj.LeadField;
        v = scalp_potentials(obj, 'time', opt.time);
        res = zeros(1, obj.NbSourceVoxels);
        for i = 1:obj.NbSourceVoxels,
            M = squeeze(A(:,:,i));
            res(i) =  norm(v-M*pinv(M)*v);
        end
        [~, pos] = min(res);
        m = pinv(A(:,:,pos))*v;
        strength = zeros(obj.NbSourceVoxels, 1);
        strength(pos) = norm(m);
        momentum = zeros(obj.NbSourceVoxels,3);
        momentum(pos,:) = m./norm(m);
        orientation = zeros(obj.NbSourceVoxels,3);
        
    otherwise
        
end

name = opt.method;
pnt = 1:obj.NbSourceVoxels;
obj.InverseSolution = struct('name', name,...
    'strength',     strength, ...
    'orientation',  orientation, ...
    'angle',        zeros(obj.NbSources,1), ...
    'pnt',          pnt, ...
    'momentum',     momentum, ...
    'activation',   ones(obj.NbSourceVoxels,1));


end