classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for topo_template criterion
    %
    % ## Usage synopsis:
    %
    % import spt.criterion.topo_template.*;
    % myConfig = config('key', value, ...);
    % myTopoTemplateCrit = topo_template(myConfig);
    %
    % ## Accepted key/value pairs:
    %
    %       * All key/value pairs accepted by class
    %         spt.criterion.rank.config
    %
    %       Template : A Kx1 numeric matrix. Default: []
    %           The candiate components' topograhies will be correlated
    %
    %
    % ## Notes:
    %
    %  * The Template property may be also set to a function_handle taking
    %  two arguments: (1) A physioset object (the data on which the spatial
    %  transformation was applied) and (2) a spt.spt object describing the
    %  spatial transformation. Such function_handle will be used to obtain
    %  the template in a data-driven fashion. See the documentation of 
    %  spt.criterion.topo_template.template_bcg for one example of such
    %  data-driven template.
    %
    % See also: topo_template
    
    % Documentation: pkg_topo_template.txt
    % Description: Configuration for topo_template criterion
  
    properties
       
        Template;
        
    end
    
    
   
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end