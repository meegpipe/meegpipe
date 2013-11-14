function obj = learn(obj, data, varargin)
% LEARN
% Learns a VAR model using one of BIOSIG's algorithms [1]
%
%
% obj = learn(obj, data)
% obj = learn(obj, data, 'algorithm', alg)
%
% where
%
% OBJ is a var.biosig object
%
% DATA is a DxN numeric matrix containing N data samples and D dimensions
%
% ALG is the name of the algorithm 
% 
% 
%
% References:
%
% [1] http://biosig.sourceforge.net/
%
%
% See also: var.biosig, var

% Description: Learn VAR model using BIOSIG
% Documentation: class_var_biosig.txt


import misc.center;
import var.arfit;
import misc.process_arguments;
import external.biosig.selmo2;
import external.biosig.mvar;

opt.algorithm = 'vieira-morf';

[~, opt] = process_arguments(opt, varargin);

switch lower(opt.algorithm),
    
    case 'vieira-morf',
        % Vieira-Morf (the default of BIOSIG's toolbox)
        mode = 2;        
    case {'lwr', 'multichannel yule-walker', 'myw'},
        % Levinson-Wiggens-Robinson
        mode = 1;
    otherwise,
        ME = MException('var:biosig:learn:InvalidAlgorithm', ...
            ['Invalid algorithm ''' opt.algorithm '''']);
        throw(ME);
end

obj.DataMean = mean(data, 2);
data = misc.center(data);

% Model order selection
X = selmo2(data, obj.MaxOrder, mode);

switch lower(obj.OrderCriterion),
    
    case 'aic',
        order = X.OPT.MVAIC-1;
        if order < obj.MinOrder,
            order = obj.MinOrder;
        end
    otherwise,
        ME = MException('var:biosig:learn:InvalidCriterion', ...
            ['Invalid criterion ''' obj.OrderCriterion '''']);
        throw(ME);
    
end

% Learn the model using BIOSIG
nDims = size(data,1);
obj.Coeffs = -X.A(:, nDims+1:nDims*(order+1));
res             = residuals(obj, data);
obj.ResCov      = cov(res');
obj.Residuals   = res;


end