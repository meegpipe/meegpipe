classdef abstract_spt < ...
        spt.spt             &  ...
        goo.printable       &  ...   % fprintf()
        goo.verbose         &  ...   % is_verbose()/set_verbose()
        goo.method_config   & ....   % set/get_method_config
        goo.abstract_named_object
    % ABSTRACT_SPT - Common ancestor for all spatial transforms
    
    properties (SetAccess = private, GetAccess = private)
        % Handling random state and random initialization
        RandState_;
        Init_;
        
        % History of components/dims selections
        ComponentSelectionH = {};
        DimSelectionH = {};
        
    end
    
    properties (SetAccess = protected, GetAccess = protected)
        
        W;                   % Projection matrix
        A;                   % Backprojection matrix
        ComponentSelection;  % Indices of selected components
        DimSelection;        % Indices of selected data dimension
        
    end
 
    properties
        LearningFilter;     % Pre-processing filter before learning
    end
    
    
    properties (Dependent)
        
        DimIn;
        DimOut;
        
    end

    methods 
       
        function val = get.DimIn(obj)            
           val = numel(obj.DimSelection);           
        end
        
        function val = get.DimOut(obj)
            val = numel(obj.ComponentSelection);
        end
        
        function obj = set.LearningFilter(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.LearningFilter = [];
                return;
            end
            
            if numel(value) ~=1 || (~isa(value, 'filter.dfilt') && ...
                    ~isa(value, 'function_handle')),
                throw(InvalidPropValue('LearningFilter', ...
                    'Must be a filter.dfilt object or a function_handle'));
            end
            
            obj.LearningFilter = value;            
            
        end
        
    end
    
    methods (Access = private)
        
        function obj = backup_selection(obj)
            
            if isempty(obj.DimSelection) && isempty(obj.ComponentSelection),
                return;
            end
            
            obj.DimSelectionH = [obj.DimSelectionH; {obj.DimSelection}];
            obj.ComponentSelectionH = [obj.ComponentSelectionH; ...
                {obj.ComponentSelection}];
            
        end
        
        
    end    
    
    methods
        
        % Mutable methods from spt.spt interface
        
        obj      = sort(obj, sortingFeature, varargin);
        
        % Method learn() is implemented in terms of learn_basis() which is to
        % be implemented by concrete classes that inherit from abstract_spt
        obj      = learn(obj, data, ev, sr);
        
        obj      = match_sources(source, target, varargin);
        
        function obj = select_component(obj, idx, varargin)
            obj = select(obj, idx, [], varargin{:});
        end
        
        function obj = select_dim(obj, idx, varargin)
            obj = select(obj, [], idx, varargin{:});
        end
        
        obj      = select(obj, compIdx, dimIdx, backup);
        
        function obj = clear_selection(obj)
           obj.ComponentSelection = 1:size(obj.W,1);
           obj.DimSelection = 1:size(obj.A,1);
        end
        
        obj = restore_selection(obj);
        
        obj      = cascade(varargin);
        
        
        % Inmutable abstract methods
        
        function W  = projmat(obj)
            W = obj.W(obj.ComponentSelection, obj.DimSelection);
        end
        
        function A  = bprojmat(obj)
            A = obj.A(obj.DimSelection, obj.ComponentSelection);
        end
        
        [data, I]   = proj(obj, data);
        
        [data, I]   = bproj(obj, data);
        
        function I = component_selection(obj)
            
            I = obj.ComponentSelection;
            
        end
        
        function I = dim_selection(obj)
            
            I = obj.DimSelection;
            
        end
        
        function val = nb_dim(obj)
            val = size(obj.W, 2);
        end
        
        function val = nb_component(obj)
            if isempty(obj.ComponentSelection),
                val = size(obj.W, 1);
            else
                val = numel(obj.ComponentSelection);
            end
        end
        
        % Random state and initialization
        function obj  = clear_state(obj)
            
            obj.Init_      = [];
            obj.RandState_ = [];
            
        end
        
        function seed = get_seed(obj)
            
            import misc.isnatural;
            
            if isempty(obj.RandState_) || ~isnatural(obj.RandState_),
                seed = randi(1e9);
            else
                seed = obj.RandState_;
            end
            
        end
        
        function obj  = set_seed(obj, value)
            
            obj.RandState_ = value;
            
        end
        
        function init = get_init(obj, ~)
            
            init = obj.Init_;
            
        end
        
        function obj = set_init(obj, value)
            
            obj.Init_ = value;
            
        end
        
        % goo.printable interface
        count = fprintf(fid, obj, varargin); % ok
        
    end
    
    methods (Abstract)
        
        obj = learn_basis(obj, data);
        
    end
    
    
    % Constructor
    methods
        
        function obj = abstract_spt(varargin)
            import misc.process_arguments;
            import misc.split_arguments;
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            obj = goo.abstract_named_object.init_goo_abstract_named_object(obj, varargin{:});
            
            obj = goo.verbose.init_goo_verbose(obj, varargin{:});
            
            parentArgs = {'Name', 'Verbose', 'VerboseLabel', 'VerboseLevel'};
            [~, thisArgs] = split_arguments(parentArgs, varargin);
            
            opt.LearningFilter = [];
            obj = set_properties(obj, opt, thisArgs{:});
            
        end
        
    end
    
    
end