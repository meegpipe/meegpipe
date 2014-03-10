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

% Documentation: class_head_mri.txt
% Description: Compute inverse solution

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
       
    otherwise
        
end

name = opt.method;
pnt = 1:obj.NbSourceVoxels;
obj.InverseSolution = struct('name', name,...
    'strength', strength, ...
    'orientation', zeros(obj.NbSourceVoxels,3), ...
    'angle', zeros(obj.NbSources,1), ...
    'pnt', pnt, ...
    'momemtum', zeros(obj.NbSourceVoxels,3), ...
    'activation', ones(obj.NbSourceVoxels,1));


end