function data = observations(obj, nSamples, nTrials, varargin)

% Description: VAR model observations
% Documentation: class_var_estimator.txt

import external.arfit.arsim;
import misc.process_varargin;
import external.randint.rand_int;

InvalidInput = MException('var:arfit:observations:InvalidInput', ...
    'Invalid input arguments');

if nargin < 2 || isempty(nSamples),
    nSamples = size(obj.Residuals, 2);
end
if nargin < 3 || isempty(nTrials),
    nTrials  = 1;
end

keySet      = {'method', 'innovations', 'sourceidx'};
method      = 'orig'; % or random, or shuffle, or shuffle all
innovations = [];
eval(process_varargin(keySet, varargin));

if isempty(innovations),
    innovations = obj.Residuals;
end

if ~ischar(method),
    throw(InvalidInput);
end

if ~isnumeric(innovations),
    throw(InvalidInput);
end

method = lower(method);
if strcmpi(method, 'random'),
    innovations = randn(size(obj.Residuals,1), nSamples*nTrials);
elseif strcmpi(method, 'shuffle'),
    innovations = obj.Residuals;
    idx = rand_int(1, size(innovations,2), nSamples*nTrials, 0, 0);
    %randperm(size(innovations,2))
    innovations = innovations(:, idx);
elseif strcmpi(method, 'shuffleall'),
    innovationsOrig = obj.Residuals;
    innovations = nan(size(innovationsOrig,1), nSamples*nTrials);
    for i = 1:size(innovations,1),
        idx = rand_int(1, size(innovationsOrig,2), nSamples*nTrials, 0, 0);
        %randperm(size(innovations,2));
        innovations(i,:) = innovationsOrig(i, idx);
    end
elseif ismember(method, {'orig', 'original'}),
    innovations = obj.Residuals;
    innovations = innovations(:, 1:nTrials*nSamples);
else
    ME = MException('var:estimator:observations:InvalidMethod', ...
        'Unknown method ''%s'' for generating the VAR observations', ...
        method);
    throw(ME);
end

data = arsim(zeros(obj.NbDims,1), obj.Coeffs, obj.ResCov, ...
    size(innovations,2), max(100,ceil(.05*size(innovations,2))), innovations')'; 

data = data + repmat(obj.DataMean, 1, size(data,2));

data = reshape(data, [size(data,1), nSamples, nTrials]);

end