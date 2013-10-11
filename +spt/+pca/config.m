classdef config < spt.generic.config
    % CONFIG - Configuration for class pca
    %
    % ## Usage synopsis:
    %
    % % Create a pca transformation object that will keep 99% of the input
    % % data variance
    % import spt.pca.*;
    % myConfig = config('Var', 99);
    % myNode   = pca(myConfig);
    %
    % % Alternatively:
    % myNode = pca('Var', 99);
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    %
    %
    % See also: spt, spt.generic

    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Var         = [0 1];
        MaxDimOut   = Inf;
        MinDimOut   = 0; % As a percentage of input dimension
        MinSamples  = 0;
        Criterion   = 'max';
        Sphering    = true;
        MaxCond     = Inf;
        
    end
    
    % Consistency checks
    methods
        
         function obj = set.Var(obj, value)
             
            import misc.ispercentage;
            import spt.generic.generic;
            import exceptions.*
            
            if isempty(value),
                obj.Var =  [0 1];
                return;
            elseif numel(value) == 1,
                value = [0 value];
            end
            if numel(value) ~= 2 || ~all(ispercentage(value)),
                throw(InvalidPropValue('Var', ...
                    'Must be a percentage range'));
            end
            obj.Var = value;
            
        end
        
        function obj = set.MaxDimOut(obj, value)
            
            import misc.isnatural;  
            import spt.generic.generic;
            import exceptions.*
            
            if isempty(value),
                obj.MaxDimOut = Inf;
                return;
            end
            
            if isa(value, 'function_handle'),
                obj.MaxDimOut = value;
                return;
            end
            
            if numel(value) > 1 || value < 0  || ...
                    (~isinf(value) && ~isnatural(value)),
                throw(InvalidPropValue('MaxDimOut', ...
                    'Must be a natural scalar'));
            end
            
            obj.MaxDimOut = value;
            
        end
        
        function obj = set.MinDimOut(obj, value)
            
            import misc.isinteger;  
            import spt.generic.generic;
            import exceptions.*
            
            if isempty(value),
                obj.MinDimOut = Inf;
                return;
            end
            
            if isa(value, 'function_handle'),
                obj.MinDimOut = value;
                return;
            end
            
            if numel(value) > 1 || value < 0  || ...
                    (~isinf(value) && ~isinteger(value)),
                throw(InvalidPropValue('MinDimOut', ...
                    'Must be a natural scalar'));
            end
            
            obj.MinDimOut = value;
            
        end
        
        function obj = set.MinSamples(obj, value)
            
            import exceptions.*
            import spt.generic.generic;
            
            if isempty(value),
                 obj.MinSamples = 0;
                return;
            end
            
            if numel(value) > 1 || value < 0,
                throw(InvalidPropValue('MinSamples', ...
                    'Must be a natural scalar'));
            end
            
            obj.MinSamples = value;
            
        end
        
        function obj = set.Criterion(obj, value)
            
            import exceptions.*
            import spt.generic.generic;
            import mperl.join;
            
            if isempty(value),
                 obj.Criterion = 'max';
                return;
            end
            
            validCrit = {'max', 'rank', 'mibs', 'aic', 'mdl'};
            
            if ~ischar(value) || ~ismember(lower(value), validCrit),
                throw(InvalidPropValue('Criterion', ...
                    ['Expected any of these => ' join(', ', validCrit)]));
            end
            
            obj.Criterion = lower(value);
            
        end
        
        function obj = set.Sphering(obj, value)
            
            import exceptions.*
            import spt.generic.generic;
            
            if isempty(value),
                 obj.Sphering = true;
                return;
            end
            
            if numel(value) ~= 1 || ~islogical(value)
                throw(InvalidPropValue('Sphering', ...
                    'Must be a logical scalar'));
            end
            
            obj.Sphering = value;
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.generic.config(varargin{:});
            
        end
        
    end
    
    
    
end