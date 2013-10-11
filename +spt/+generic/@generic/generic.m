classdef generic < ...
        spt.spt                     & ...
        goo.abstract_configurable   & ...
        goo.verbose                 & ...
        goo.abstract_named_object   & ...
        goo.printable
    % generic - An abstract class for generic spatial transformations
    %
    % See: <a href="matlab:misc.md_help('spt.generic')">misc.md_help(''spt.generic'')</a>
    
    
   
    
    
    %% IMPLEMENTATION .....................................................
    properties (SetAccess = private, GetAccess = private)
        MethodConfig = spt.generic.default_method_config;
    end
    
    properties (SetAccess = protected, GetAccess = protected)
        
        W;                  % Forward projection matrix.
        A;                  % Backward projection matrix.
        Wi;                 % Dataset specific forward projection matrix
        Ai;                 % Dataset specific backward projection matrix
        Selected;           % Indices of the selected components
        
    end
    
    methods (Access = private)
        
        obj = learn_multiset(obj, data, varargin);
        
    end
    
    methods (Access = protected)
        
        myTable = parse_disp(obj);
        
    end
    
    
    %% PUBLIC INTERFACE ...................................................
    
    properties (Dependent)
        
        DimOut;         % The dimensionality of the projected data
        DimIn;          % The dimensionality of the input data
        NbComp;         % Number of spatial components
        
    end
    
    % Dependent properties
    methods
        
        function value = get.DimOut(obj)
            
            value = numel(find(obj.Selected));
            
        end
        
        function value = get.DimIn(obj)
            
            value = size(obj.W, 2);
            
        end
        
        function value = get.NbComp(obj)
            
            value = size(obj.W, 1);
            
        end
        
        
    end
    
    
    % To be implemented by children classes
    methods (Abstract)
        
        [W, A, selection, obj] = learn_basis(obj, data, ev, varargin);
        
    end
    
    % goo.printable interface
    methods
        
        count = fprintf(fid, obj);
        
    end
    
    % spt.spt interface
    methods
        
        %% Mutable abstract methods
        
        obj          = learn(obj, data, ev, sr);
        
        obj          = learn_dualreg(obj, data);
        
        obj          = match_sources(obj, A, varargin);
        
        obj          = select(obj, idx);
        
        obj          = deselect(obj, idx);
        
        obj          = clear_selection(obj);
        
        obj          = set_basis(obj, W, A);
        
        obj          = cascade(objArray);
        
        obj          = lmap(obj, W);
        
        obj          = rmap(obj, W);
        
        obj          = reorder(obj, idx);
        
        obj          = set_method_config(obj, varargin);
        
        %% Inmutable (const) abstract methods
        
        data         = data4learning(obj, data, varargin);
        
        W            = projmat(obj);
        
        A            = bprojmat(obj);
        
        [data, idx]  = proj(obj, data);
        
        [data, idx]  = bproj(obj, data);
        
        idx          = selection(obj);
        
        cfg          = get_method_config(obj, varargin);
        
    end
    
    % Reimplementation of default configurable methods
    methods
        
        disp_body(obj);
        
    end
    
    % Declared and implemented in this class
    methods
        
        bool     = is_delay_embedded(obj);
        
    end
    
    % Abstract constructor
    methods
        
        function obj = generic(varargin)
            
            obj = obj@goo.abstract_configurable(varargin{:});
            
            % Ensure that each object has an independent method config
            obj.MethodConfig = spt.generic.default_method_config;
        end
        
    end
    
end