function obj = learn(obj, data, varargin)
% LEARN
% Learns a VAR model using ARFIT [1]
%
%
% obj = learn(obj, data)
%
% obj = learn(obj, data, 'key', value, ...)
%
%
% where
%
% OBJ is a var.arfit object
%
% DATA is a DxN numeric matrix containing N data samples and D dimensions
%
%
% Accepted key/value pairs:
%
% 'Verbose'         : (logical) If set to true, status messages will be
%                     displayed. 
%                     Default: true
%
% 'NoiseEstimation' : (logical) If set to true, the noise covariance matrix
%                     will be also estimated. 
%                     Default: false
%
% 'ResidualReject'  : (logical) If set to true, the estimated residuals
%                     will be processed in order to reject "bad" residuals,
%                     i.e. residual samples that have extremely large or
%                     abnormally low variance. 
%                     Default: false
%
% Reference:
%
% [1] The ARFIT toolbox: http://www.gps.caltech.edu/~tapio/arfit/
%
% See also: var.arfit, var

% Description: Learn VAR model using ARFIT
% Documentation: class_var_arfit.txt

import misc.center;
import misc.process_varargin;

keySet          = {'verbose', 'noiseestimation','residualreject'};
verbose         = obj.Verbose;
noiseestimation = false;
residualreject  = false;
eval(process_varargin(keySet, varargin));

obj.DataMean = mean(data, 2);
data = misc.center(data, 'verbose', false);

if verbose,
    verboseLabel = ['(' class(obj) ':learn) '];
end

if obj.AR
    coeffs = cell(1, size(data,1));
    order  = 0;
    for i = 1:size(data, 1),
        [~, coeffs{i}] = learn_coeffs(obj.Algorithm, data(i,:));
        order = max(order, numel(coeffs{i}));
    end
    
    tmp = zeros(size(data,1), size(data,1), order);
    for i = 1:size(data,1),
        tmp(i,i,:) = coeffs{i};
    end
    obj.Coeffs = reshape(tmp, size(data,1), size(data,1)*order);
    
else    
    % PCA
    if ~isempty(obj.PCA),
        pcaObj = learn(obj.PCA, data, 'verbose', verbose);    
        data = project(pcaObj, data, 'verbose', verbose);
    end
    
    Gcond = Inf;
    G=1;
    firstIter = true;
    while isinf(obj.MaxCond) || Gcond/size(G,1) > obj.MaxCond,
        if ~firstIter
            if pstar < 2,
                ME = MException('var:arfit:IllConditionedModel', ...
                    'VAR model is ill conditioned. Try reducing the dimensionality of the model.');
                throw(ME);
            end
            if verbose,
                fprintf([verboseLabel 'VAR model of order %d is ill conditioned. ' ...
                    'Trying order %d...\n\n'], pstar, pstar-1);
            end
            obj.MaxOrder = pstar-1;
        end
        firstIter = false;
        coeffs = learn_coeffs(obj.Algorithm, data);
        
        m = size(coeffs,1);
        pstar = size(coeffs,2)/m;
        if verbose,
            fprintf([verboseLabel 'Learned a VAR model of order %d\n\n'], ...
                pstar);
        end
        
        if verbose,
            fprintf([verboseLabel 'Checking VAR model...\n\n']);
        end      
        
        G = [coeffs; zeros(m*(pstar-1), m*pstar)];
        G = eye((m*pstar)^2,(m*pstar)^2)-kron(G,G);
        for i = 2:pstar,
            G((i-1)*m+1:i*m, (i-2)*m+1:(i-1)*m) = eye(m);
        end
        if size(G,1) < 2000,
            Gcond = cond(G);
        else
            Gcond = 0;
            idx = randperm(size(G,1));
            for i = 1:10
               Gcond = max(Gcond, cond(G(idx(1:1000),idx(1:1000))));  
            end
        end
        if isinf(obj.MaxCond),
            break;
        end
    end
    
    if ~isempty(obj.PCA),
        order = round(size(coeffs, 2)/size(coeffs,1));
        coeffs = reshape(coeffs, [size(coeffs,1), size(coeffs,1), order]);
        bpCoeffs = nan(size(coeffs));
        A = bprojection_matrix(pcaObj);
        W = projection_matrix(pcaObj);
        for i = 1:order
            bpCoeffs(:,:,i) = A*squeeze(coeffs(:,:,i))*W;
        end
        obj.Coeffs = reshape(bpCoeffs, size(coeffs,1), size(coeffs,1)*order);
    else
        obj.Coeffs = coeffs;
    end
    
end

if verbose, 
    fprintf([verboseLabel ...
        'Learned a %d-dimensional VAR model of order %d\n\n'], ...
        obj.NbDims, obj.Order);
end

if noiseestimation,
    if verbose, %#ok<UNRCH>
        fprintf([verboseLabel 'Learning noise covariance...\n\n']);
    end
    obj.NoiseCov = noise_cov(obj);
else
    obj.NoiseCov = [];
end

res             = residuals(obj, data);

% Reject bad samples from the residuals
if residualreject,
    res = import(pset.import.matrix, res); %#ok<UNRCH>
    [~, res] = bad_samples(res);
    res = res(:, ~res.BadSample);
    res = medfilt1(res', 4)';
end
obj.ResCov      = cov(res');
obj.Residuals   = res;


end