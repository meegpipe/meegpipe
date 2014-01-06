function myNode = eog(varargin)

% Do not display any warning yet...
% warning('eog:Obsolete', ...
%     ['meegpipe.node.bss.eog is obsolete and will be removed. \n' ...
%     'Use aar.eog.bss_psd_ratio instead']);
    
myNode = aar.eog.bss_psd_ratio(varargin{:});

end