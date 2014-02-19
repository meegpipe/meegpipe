function myNode = eog(varargin)
% EOG - Default EOG correction node

myNode = aar.eog.bss_psd_ratio(varargin{:});

end