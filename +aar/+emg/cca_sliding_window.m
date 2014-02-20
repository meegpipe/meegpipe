function myNode = cca_sliding_window(varargin)
% CCA_SLIDING_WINDOW - EMG correction using sliding window CCA
%
% 
% myNode = aar.emg.cca_sliding_window('key', value, ...)
%
% 
% Accepted key/value configuration pairs:
%
% WindowLength      :  The length of the sliding window in seconds    
%                      Default: 5
% 
% Correction        :  A correction threshold in percentage. Increasing
%                      Correction will lead to harsher correction.
%                      Defaul: 10
%
%
% Default configuration:
%
% The default values for the configuration key/values listed above can be
% obtained as follows:
%
% aar.emg.cca_sliding_window.default_[key]
%
% For instance, the default WindowLength:
%
% aar.emg.cca_sliding_window.default_WindowLength
%
%
% See also: filter.cca, bss.node.filter, filter.sliding_window


import misc.process_arguments;
import misc.split_arguments;
import aar.emg.cca_sliding_window.*;

opt.WindowLength = 5;
opt.CorrectionTh = 20;
opt.VarTh        = 99.99;         
[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

if opt.CorrectionTh < 1,
    warning('cca_sliding_window:CorrectionThMustBePercentage', ...
        'CorrectionTh < 1. Are you sure CorrectionTh is a percentage?');
end

if opt.CorrectionTh < 0 || opt.CorrectionTh > 100
   error('cca_sliding_window:CorrectionThMustBePercentage', ...
       'Invalid CorrectionTh: must be a percentage (in the range 0-100)'); 
end

myPCA = spt.pca('RetainedVar', opt.VarTh);

myCCA = spt.bss.cca('MinCorr', opt.CorrectionTh/100);
myFilter = filter.cca('CCA', myCCA);
myFilter = filter.sliding_window(myFilter, ...
    'WindowLength', @(sr) opt.WindowLength*sr);

myNode = meegpipe.node.filter.new(...
    'Filter', myFilter, ...
    'PCA',    myPCA, ...
    varargin{:});


end