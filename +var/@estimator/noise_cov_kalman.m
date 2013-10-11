function Sigma = noise_cov_kalman(obj, varargin)
% NOISE_COV_KALMAN
%
% Noise covariance estimation using Kalman filtering [1]
%
%
% sigma = noise_cov_kalman(obj)
%
% sigma = noise_cov_kalman(obj, 'key', value, ...)
%
% 
% Where
%
% OBJ is a var.estimator object
%
% SIGMA is the estimated noise covariance matrix
%
%
% Accepted key/value pairs:
%
% 'verbose'     : (logical) If true, status messages will be displayed.
%                 Default: true
%
%
% Notes:
%
% * This method requires package external.kalmangc
% 
%
% References:
%
% [1] Nalatore et al., 2007, Mitigating the effects of measurement noise on
%     Granger causality, PRE 75, 031123.
%
%
% See also: var.estimator, var.estimator.noise_cov

% Documentation: class_var_estimator.txt
% Description: Noise covariance estimation using Kalman Filtering

import external.kalmangc.denoise_by_KalmanEM;
import misc.process_varargin;

keySet = {'verbose'};
verbose = true;
eval(process_varargin(keySet, varargin));

data = observations(obj);
denoisedObservations = denoise_by_KalmanEM(data, 1, ...
    size(data,2), obj.Order, verbose);
noise = data-denoisedObservations;
Sigma = cov(noise');