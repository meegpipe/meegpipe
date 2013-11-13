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
        
    end
    
    properties (SetAccess = protected, GetAccess = protected)
        
        W;                   % Projection matrix
        A;                   % Backprojection matrix
        ComponentSelection;  % Indices of selected components
        DimSelection;        % Indices of selected data dimensions     
 
    end
    
    methods (Access = protected)
       
        function obj = set_properties(obj, opt, varargin)
           
            import misc.process_arguments;
            
            [~, opt] = process_arguments(opt, varargin);
            fNames = fieldnames(opt);
            for i = 1:numel(fNames)
                obj.(fNames{i}) = opt.(fNames{i});
            end
            
            
        end
    end
    
    methods
        
        % Mutable methods from spt.spt interface
        
        % Method learn() is implemented in terms of learn_basis() which is to
        % be implemented by concrete classes that inherit from abstract_spt
        obj      = learn(obj, data, ev, sr);
        
        obj      = match_sources(source, target, varargin);
        
        obj      = select_component(obj, idx, backup);
        
        obj      = select_dim(obj, idx, backup);
        
        obj      = invert_component_selection(obj, backup);
        
        obj      = invert_dim_selection(obj, backup);
        
        obj      = clear_selection(obj);
        
        obj      = restore_selection(obj);
        
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
        
        I           = component_selection(obj);
        
        I           = dim_selection(obj);
        
        function val = nb_dim(obj)
            val = size(obj.W, 2);
        end
        
        function val = nb_component(obj)
            val = size(obj.W, 1);
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
            
            if nargin < 1, return; end
            
            obj = goo.abstract_named_object.init_goo_abstract_named_object(obj, varargin{:});
            
            obj = goo.verbose.init_goo_verbose(obj, varargin{:});
            
        end
        
    end
    
    
end