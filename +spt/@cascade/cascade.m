classdef cascade < spt.generic.generic
    % CASCADE - A cascade of two or more spatial transforms
    %
    % ## Construction
    %
    % obj = cascade(x1, x2, ...)
    %
    % Where
    %
    % X1, X2, ... are spt.spt objects. Alternatively, X1, X2, ... can be a
    % cell array of two elements, the first of which is a spt.spt object,
    % and the second of which is a spt.criterion. A spt.spt object together
    % with a spt.criterion object can be used to specify a transformation
    % that (possibly) reduces the dimensionality of the input data.
    %
    % OBJ is a spt.cascade object
    %
    %
    % ## Usage synopsis:
    %
    % % Build a cascade spatial transformation that projects the input data
    % % into its principal components (with a variance threshold of 99%)
    % % and subsequently applies JADE to the found principal components
    % import spt.cascade;
    % x1  = spt.pca('Var', .99);
    % x2  = spt.jade;
    % obj = cascade(x1, x2);
    % X   = rand(4,1000);    % Some sample data
    % obj = learn(obj, X);   % Learn the cascade spatial transform
    % ics = proj(obj, X);    % The estimated independent components
    % 
    % 
    % % Build a cascade that (i) performs JADE on the input data, (ii) 
    % % selects those components that do not look EOG-related, (iii)
    % % performs MULTICOMBI on the latter components, (iv) selects from the
    % % MULTICOMBI components those that have high autocorrelations at lag 
    % % 10
    % import spt.cascade;
    % import spt.criterion.tsparse;
    % import spt.criterion.acf;
    % % The MinCart argument is used to force the rejection of at least one
    % % component
    % eogCritObj = tsparse.eog('MinCard', 1, 'Negated', true);
    % acfCritObj = acf('SamplingRate', 1, 'Period', 10, ...
    %   'MinCard', 1, 'MaxCard', 1, 'Negated', true); 
    % obj = cascade({spt.jade, eogCritObj}, {spt.multicombi, acfCritObj});
    % X   = randn(5, 1000);
    % obj = learn(obj, X);    
    % ics = proj(obj, X);   % Only 3 independent components!
    % 
    %
    % See also: spt.spt, spt.criterion
    
    % Description: Cascade of two or more spatial transforms
    % Documentation: class_spt_cascade.txt
    
    % Exceptions that may be thrown by methods of this class
    methods (Static, Access = private)
        function obj = InvalidTransform(idx, msg)
           if nargin < 1 || ~isnumeric(idx), idx = []; end
           if nargin < 2, msg = ''; end
           if isempty(idx),
               msg = sprintf('Invalid transform specification: %s', msg);              
           else
               msg = sprintf(...
                   'The transform with index %d is invalid: %s', idx, msg);
           end
           obj = MException('spt:cascade:InvalidTransform', ...
               msg); 
        end
    end
    
    
    % Public interface ....................................................
    properties (SetAccess = private)
        Node; 
        Criterion;
    end
    
    % Constructor
    methods
        function obj = cascade(varargin)      
            import spt.cascade;
            obj.Node = cell(1, numel(varargin));
            obj.Criterion = cell(1, numel(varargin));
            for i = 1:nargin               
                if ~iscell(varargin{i}),
                    varargin(i) = {varargin(i)};
                end                
                if ~isa(varargin{i}{1}, 'spt.spt'),                                
                    throw(cascade.InvalidTransform(i, ...
                        'A spt.spt object was expected'));
                end               
                obj.Node{i} = varargin{i}{1};
                if numel(varargin{i}) == 2,
                    if ~isa(varargin{i}{2}, ...
                            'spt.criterion.criterion')                       
                        throw(cascade.InvalidTransform(i, ...
                            'A spt.criterion.criterion object was expected'));
                    end
                    obj.Criterion{i} = varargin{i}{2};
                elseif numel(varargin{i}) > 2
                    throw(cascade.InvalidTransform(i));
                end
            end
        end        
    end      
   
    methods 
        obj = learn(obj, data, varargin);
        % Just to be able to inherit from spt.generic.generic:
        obj = learn_basis(obj, data, varargin);
    end
    
    
    
end