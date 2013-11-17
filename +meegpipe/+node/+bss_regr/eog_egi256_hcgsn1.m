function obj = eog_egi256_hcgsn1(varargin)
% eog_egi256_hcgsn1 - Rejects EOG components using topography
%
% This node pre-configuration should be used only in combination with an
% EGI 256 sensor net HCGSN v1.0.
%
% See also: bss_regr.eog

import meegpipe.node.*;
import misc.split_arguments;

opt.MinCard    = 2;
opt.MaxCard    = 5;
opt.Max        = 15;

[critArgs, varargin] = split_arguments(fieldnames(opt), varargin);

myFeat = spt.feature.topo_ratio.eog_egi256_hcgsn1;
myCrit = spt.criterion.threshold(myFeat, critArgs{:});

obj = bss_regr.eog(...
    'Criterion', myCrit, ...
    'Name',     'eog-topo', ...
    varargin{:});


end