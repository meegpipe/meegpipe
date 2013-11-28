classdef matrix < spt.abstract_spt
    % MATRIX - Builds a dummy BSS object based on user-defined proj/bproj
    % matrix
    
    methods
        function obj = learn_basis(obj, ~, varargin)
           % A dummy method 
        end
    end
    
    methods
        
        function obj = matrix(W, A, varargin)
            import misc.set_properties;
            obj = obj@spt.abstract_spt(varargin{:}); 
            
            obj.W = W;
            obj.A = A;
            obj.ComponentSelection = 1:size(W, 1);
            obj.DimSelection = 1:size(A,1);
        end
        
    end
    
    
end