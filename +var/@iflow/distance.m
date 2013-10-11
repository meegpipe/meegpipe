function value = distance(x,y,type)
% DISTANCE Computes the distance between a pair of SyncIndexMVAR objects
%   

if nargin < 3, type = 'mse'; end

if nargin < 2,
    error('error:notEnoughInput','Two input parameters are required.');
end

if any(size(x)~=size(y)),
    error('error:invalidDimensions','The data properties of the two input objects have different dimensions.');
end


switch lower(type),
    case 'mse',
        value = abs(abs(x.Flow)-abs(y.Flow));
        value = sum(value(:))./numel(x.Flow);
    case 'msenorm',
        value = abs(abs(x.Flow)-abs(y.Flow))./abs(x.Flow);
        value = sum(value(:))./numel(x.Flow);
    otherwise,
        error('error:invalidType','Unknown type of error measure ''%s''.',type);
end

