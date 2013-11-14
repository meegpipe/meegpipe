function Sigma = noise_cov(obj, varargin)
% NOISE_COV - Noise covariance estimation
%
%
% sigma = noise_cov(obj)
%
% sigma = noise_cov(obj, 'key', value, ...)
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
% 'fc'        :  (double) Cutoff of the high-pass filter used to estimate
%                estimate the noise covariance matrix. The value of fc is
%                normalized and should be equal to the approximate frequency
%                above which noise predominates. Default: fc = .75
%
% 'sigFactor' :  (double) A scalar that provides a rough approximation of 
%                the amount of signal that is to be expected in the
%                high-frequency band. It must be a value from 0 (no signal
%                at all) to 1 (only signal). Default: 0.01
%
% 'verbose' :   (logical) If true, status messages will be displayed
%               Default: true
%
%
%
% See also: var.estimator.noise_cov_kalman, var.estimator, var

% Documentation: class_var_estimator.txt
% Description: Noise covariance estimation

import filter.hpfilt;
import misc.process_varargin;

keySet = {'fc', 'verbose', 'sigfactor'};
fc = .75;
verbose = false;
sigfactor = 0.01;

eval(process_varargin(keySet, varargin));

data = observations(obj, [], [], 'method', 'orig');

data = filter(hpfilt('fc', fc, 'verbose', verbose), data);

Sigma = 1/(1-fc)*(1-sigfactor)*cov(data');

end