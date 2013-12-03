classdef cca < spt.abstract_spt
    % CCA - BSS using Canonical Correlation Analysis
    
    properties (SetAccess = private, GetAccess = private)
       CorrVal = []; 
    end
    
    properties
        Delay = 1;
    end
    
    methods
        
        function obj = learn_basis(obj, X, varargin)
            
            T = size(X, 2);
            
            % correlation matrices
            if isa(X, 'pset.mmappset'),
                select(X, [], obj.Delay+1:T);
                Y = subset(X);
                clear_selection(X);
                select(X, [], 1:T-obj.Delay);
                center(X);
                center(Y);
                Ytrans = transpose(copy(Y));
                Xtrans = transpose(copy(X));
            else
                Y = X(:,obj.Delay+1:end);
                X = X(:,1:end-obj.Delay);
                X = X - repmat(mean(X,2), 1, size(X,2));
                Y = Y - repmat(mean(Y,2), 1, size(Y,2));
                Ytrans = transpose(Y);
                Xtrans = transpose(X);
            end
            
            Cyy = (1/T)*(Y*Ytrans);
            Cxx = (1/T)*(X*Xtrans);
            Cxy = (1/T)*(X*Ytrans);
            Cyx = (Cxy');
            invCyy = pinv(Cyy);
            
            if isa(X, 'pset.mmappset'),
                restore_selection(X);
            end
            
            % calculate W
            [W,r] = eig(pinv(Cxx)*Cxy*invCyy*Cyx);
            r = sqrt(abs(real(r)));
            [r, I] = sort(diag(r),'descend');
            obj.W = W(:,I)';
            obj.A = pinv(obj.W);
            obj.ComponentSelection = 1:size(obj.W,1);
            obj.DimSelection       = 1:size(X,1);
            obj.CorrVal = r;
            
        end
        
        function corrVal = get_component_correlation(obj, idx)
            
            if nargin < 2 || isempty(idx),
                idx = 1:numel(obj.CorrVal);
            end
            
            corrVal = obj.CorrVal(idx);
            
        end
        
        function obj = cca(varargin)
            import misc.set_properties;
            import misc.split_arguments;
            
            opt.Delay = 1;
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});
            
            obj = set_properties(obj, opt, thisArgs);
            
        end
        
    end
    
    
    
end

