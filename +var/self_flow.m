function out = self_flow(x, t_array, freq_array, varargin)
% SELF_FLOW - Indices of self-flow using Vector Autoregressive models
%
% Usage:
%   >> Y = self_flow(X, T, F)
%   >> Y = self_flow(X, T, F, 'opt1', val1, ..., 'optn', valn)
%
% Inputs:
%   X   - Signal (a 1xN vector of scalar values)
%   T   - Time shifts, in samples (a 1xM vector of scalar values)
%   F   - Normalized frequency bins (a 1xK vector of scalar values in the
%         range [0 1]).
%
% Outputs:
%   Y   - The computed flow indices (a KxM vector of scalar values)
%         
%
% Optional option/value pairs (case insensitive):
%
%   pmin: Scalar (defaults to 1)
%       Minimum VAR model order
%
%   pmax: Scalar (defaults to 15)
%       Maximum VAR model order
%
%   selector: Char array (defaults to 'SBC')
%       Criterion for VAR model order selection. Allowed values are those
%       accepted by function arfit from the ARFIT toolbox.
%       
%
%
%
% See also: misc


import misc.center;
import misc.pdc;
import misc.dtf;
import misc.process_varargin;
import misc.globals;

if nargin < 3 || isempty(freq_array),
    freq_array = linspace(0,1,10);
end

if nargin < 2 || isempty(t_array),
    t_array = 1;
end

if nargin < 1,
    error('misc:spdc:invalidInput', ...
        'A signal is expected as first input argument');
end

n_f = length(freq_array);
n_t = length(t_array);

% Optional arguments accepted by this function
THIS_OPTIONS = {'pmin','pmax','selector'};

% Default options
pmin = 1;
pmax = 15;
selector = 'sbc';

eval(process_varargin(THIS_OPTIONS, varargin));

x = center(reshape(x, 1, length(x)));
out.pdc = nan(n_f, n_t);
out.dtf = nan(n_f, n_t);
out.ddtf = nan(n_f, n_t);
out.ffdtf = nan(n_f, n_t);
for t = 1:length(t_array)
   y = circshift(x, [0 -t]); 
   % Estimate VAR parameters
   v = [x;y];
   [~, A, C] = arfit(v, pmin, pmax, selector, 'zero', 1);
   % Estimate the pdc/dtf/ddtf/ffdtf   
   tmp = pdc(A, freq_array);
   out.pdc(:, t) = abs(squeeze(tmp(2,1,:)));
   tmp = dtf(A, C, freq_array, 'dtf');
   out.dtf(:, t) = abs(squeeze(tmp(2,1,:)));
   tmp = dtf(A, C, freq_array, 'ddtf');
   out.ddtf(:, t) = abs(squeeze(tmp(2,1,:)));
   tmp = dtf(A, C, freq_array, 'ffdtf');
   out.ffdtf(:, t) = abs(squeeze(tmp(2,1,:)));    
   fprintf('.');
end