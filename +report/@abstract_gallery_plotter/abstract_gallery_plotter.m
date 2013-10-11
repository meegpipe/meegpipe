classdef abstract_gallery_plotter < ...
        report.gallery_plotter              & ...
        goo.abstract_configurable_handle    & ...
        goo.reportable_handle               & ...
        goo.verbose_handle                  & ...
        goo.abstract_named_object_handle
    
  
    % goo.reportable interface
    methods
        
        function str = whatfor(~)
            
            str = '';
            
        end
        
        % Children will probably want to redefine method report_info
        function [pName, pValue, pDescr]   = report_info(obj, varargin)
            
            [pName, pValue, pDescr]   = report_info(get_config(obj));
            
        end
        
    end
    
   
    % abstract constructor
    methods
        
        function obj = abstract_gallery_plotter(varargin)
            
            obj = obj@goo.abstract_configurable_handle(varargin{:});
           
            
        end
        
    end
    
    
end