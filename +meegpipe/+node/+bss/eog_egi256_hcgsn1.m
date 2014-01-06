function myNode = eog_egi256_hcgsn1(varargin)
% EOG_EGI256_HCGSN1 - EOG correction for EGI's HCGSN1 net using topograhies

% Do not display any warning yet...
% warning('bss:Obsolete', ...
%     ['meegpipe.node.bss.eog_egi256_hcgs1 is obsolete and will be removed\n', ...
%     'Use aar.eog.topo_egi256_hcgs1 instead']);

      
myNode = aar.eog.topo_egi256_hcgsn1(varargin{:});

end