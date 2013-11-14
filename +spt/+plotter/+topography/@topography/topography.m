classdef topography < ...
        report.abstract_gallery_plotter & ...
        goo.verbose_handle
    
  
    % Public interface ....................................................
    methods
        % report.plotter interface
        [h, groups, captions, extra, extraCap, config] = plot(obj, ...
            sensors, data, dataName);
     
    end
    
    % Constructor
    methods 
        
        function obj = topography(varargin)
           
           import spt.plotter.topography.*;
            
           if nargin < 1,
               obj = set_config(obj, config);
           elseif nargin == 1,
               obj = set_config(obj, varargin{1});
           else
               obj = set_config(obj, config(varargin{:}));
           end
        end
        
    end
    
    
end