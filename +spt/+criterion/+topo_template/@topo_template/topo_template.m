classdef topo_template < spt.criterion.rank.rank
    % TOPO_TEMPLATE - Select components by cross-correlating topographies
    %
    % ## Usage synopsis:
    %
    % % Select the spatial component whose topography matches best the
    % % provided template topography
    % import spt.criterion.topo_template.*;
    % critObj = topo_template('Template', myTemplate, 'MinCard', 1, ...
    %       'MaxCard', 1);
    % [selected, rIndex] = select(critObj, sptObj);
    % 
    %
    % See also: config
    
    % Documentation: class_topo_template.txt
    % Description: Cross-correlation with template topography
    
    methods
        
        idx = compute_rank(obj, sptObj, varargin);
        
    end
    
    % Static constructors
    methods (Static)
       
        obj = bcg(varargin);
        
    end
    
    % Constructor
    methods
       
        function obj = topo_template(varargin)
            
            obj = obj@spt.criterion.rank.rank(varargin{:});
            
        end
        
        
    end
    
    
end