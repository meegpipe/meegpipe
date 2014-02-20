function myNode = lasip_fit(varargin)

warning('node:bss:deprecated', ...
    ['This function has been deprecated. ' ...
    'Use aar.misc.lpa_noise instead']);

myNode = aar.misc.lpa_noise(varargin{:});


end