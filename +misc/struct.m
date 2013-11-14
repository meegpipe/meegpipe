function out = struct(varargin)
% STRUCT -


for i = 1:2:numel(varargin)
   out.(varargin{i}) = varargin{i+1}; 
end



end