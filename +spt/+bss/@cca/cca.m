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
            
            import misc.process_arguments;
            
            opt.SamplingRate = [];
            [~, opt] = process_arguments(opt, varargin);
            
            T = size(X, 2);
            delay = obj.Delay;
            
            if isa(delay, 'function_handle'),
                % Delay can be a function_handle of the input to the
                % filter. This is handy when we want delay to be expressed
                % in seconds. It also allows for adaptive-delay schemes in
                % which the delay is obtained as a function of the input
                % data.
               if isa(X, 'physioset.physioset'),
                   delay = delay(X); 
               elseif ~isempty(opt.SamplingRate),
                   delay = delay(opt.SamplingRate);
               else
                   error('Invalid/missing CCA delay');
               end
            end
            % Special case, Delay is an array of possible delays. Pick that
            % delay that maximizes auto-correlation in the SUM dataset            
            if numel(delay) > 1,
                corrF = zeros(size(X,1), numel(delay));
                for i = 1:numel(delay)
                    for j = 1:size(X,1),
                        thisX = X(j,:) - mean(X(j,:));
                        thisX = thisX./sqrt(var(thisX));
                        thisCorr = ...
                            thisX(1:end-delay(i))*thisX(delay(i)+1:end)';
                        thisCorr = thisCorr/(numel(thisX)-delay(i));
                        corrF(j,i) = thisCorr;
                    end
                end
                corrF = prctile(abs(corrF), .75, 1);  
                [~, Imax] = max(corrF);
                delay = delay(Imax);
            end
            
            % correlation matrices
            if isa(X, 'pset.mmappset'),
                select(X, [], delay+1:T);
                Y = subset(X);
                clear_selection(X);
                select(X, [], 1:T-delay);
                center(X);
                center(Y);
                Ytrans = transpose(copy(Y));
                Xtrans = transpose(copy(X));
            else
                Y = X(:,delay+1:end);
                X = X(:,1:end-delay);
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

