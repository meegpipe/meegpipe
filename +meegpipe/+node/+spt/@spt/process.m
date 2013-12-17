function [data, dataNew] = process(obj, data, varargin)
% PROCESS - Main processing method for spt nodes

import goo.globals;
import misc.eta;
import meegpipe.node.filter.filter;

dataNew = [];

sptObj          = get_config(obj, 'SPT');
pca             = get_config(obj, 'PCA');


if ~isempty(pca),
    pca = learn(pca, data);
    proj(pca, data);
end

sptObj = learn(sptObj, data);
proj(sptObj, data);


end