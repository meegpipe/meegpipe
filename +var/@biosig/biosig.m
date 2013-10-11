classdef biosig < var.estimator
    
    % Constructor
    methods
        function obj = biosig(varargin)            
           
           obj = obj@var.estimator('OrderCriterion', 'aic', varargin{:});                                
           
        end    
        
    end   
    
    % var.estimator interface
    methods
        obj  = learn(obj, data, varargin);
        crit = criteria(obj);
    end         
    
end