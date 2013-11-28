function fObj = eog(varargin)
% EOG - LASIP filter for EOG-like spatial components
%
% fObj = filter.lasip.eog();
% fObj = filter.lasip.eog('key', value, ...)
%
% Any provided key/value pair will be passed directly to the constructor of
% the LASIP filter.
%
% See also: filter


fObj = filter.lasip('Gamma', 3.5:0.25:5.5, 'Decimation',5, varargin{:});


end