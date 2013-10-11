classdef dummy < spt.generic.generic

    % From spt.generic.generic
    methods
        function [W, A, selection, obj] = learn_basis(obj, data, varargin)
           W = eye(size(data,1));
           A = W;
           selection = 1:size(data,1);
        end
    end
    
    % Constructor
    methods
        function obj = dummy(varargin)
            obj = obj@spt.generic.generic(varargin{:});
        end
        
    end


end