classdef good_data < pset.selector.abstract_selector
    % GOOD_DATA - Selects only good channels and samples from physioset
    %
    % ## Usage synopsis:
    %
    % import pset.*;
    %
    % % Create sample physioset
    % X = randn(10,1000);
    % data = import(pset.import.matrix, X);
    %
    % % Mark some bad samples and bad channels
    % set_bad_channel(data, 4:5);
    % set_bad_sample(data, 100:500);
    %
    % % Construct a selector object
    % mySelector = selector.good_data;
    %
    % % Select good data from out sample dataset
    % select(mySelector, data)
    %
    % % Must be OK
    % import test.simple.ok;
    % X = X(4:5, 501:end);
    % ok(size(data,1) == 2 && size(data,2) == 500 && ...
    %   max(abs(data(:) - X(:)))<1e-3);
    %
    % See also: selector
  
    %% IMPLEMENTATION 
    
    properties (SetAccess = private, GetAccess = private)        
     
        Negated             = false;
        
    end
    
    
    %% PUBLIC INTERFACE ....................................................
   
    % pset.selector.selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = true;
            
        end
        
        function data = select(obj, data, remember)
            
            if nargin < 3 || isempty(remember),
                remember = true;
            end
            
            if obj.Negated,
                
                select(data, is_bad_channel(data), is_bad_sample(data), ...
                    remember);
                
            else
                
                select(data, ~is_bad_channel(data), ~is_bad_sample(data), ...
                    remember);
                
            end
           
        end                
        
    end
    
    % Public methods declared and defined here
    
    methods
        
        function disp(obj)
            
            import goo.disp_class_info;
           
            disp_class_info(obj);
           
            if obj.Negated,
                fprintf('%20s : yes\n', 'Negated');
            else
                fprintf('%20s : no\n', 'Negated');
            end
            
        end        
        
    end
    
    
    
    
end