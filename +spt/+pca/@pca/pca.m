classdef pca < spt.generic.generic
    % pca - Principal Component Analysis
    %
    % See: <a href="matlab:misc.md_help('spt.pca')">misc.md_help(''spt.pca'')</a>
    
    
    
    %% IMPLEMENTATION .....................................................
    properties (SetAccess = private, GetAccess = private)
        
        Samples;
        Eigenvalues;
        Eigenvectors;
        CriterionValues;
        DimOpt;
        
    end
    
    methods (Access = private, Static)
        
        y = logpk(eigVal)
        
    end
    
    %% PUBLIC INTERFACE ...................................................
    
    
    % spt.spt interface
    methods
        
        [W, A, selection, obj] = learn_basis(obj, data, varargin);
        
        % reimplementation of that of spt.generic.generic
        disp_body(obj);
        
    end
    
    % Methods declared and defined here
    methods
        
        count = fprintf(fid, obj, gallery, makeFig);
        
    end
    
    methods (Static)
        
        % Component selection methods
        
        [kOpt, pk] = mibs(eigValues, n, varargin)
        
        [kOpt, pk] = aic(eigValues, n, varargin)
        
        [kOpt, pk] = mdl(eigValues, n, varargin)
        
    end
    
    % Constructor
    methods
        
        function obj = pca(varargin)
            
            import misc.struct2cell;
            import misc.process_arguments;
            
            obj = obj@spt.generic.generic(varargin{:});
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'pca');
            end
            
            
        end
        
    end
    
    
end