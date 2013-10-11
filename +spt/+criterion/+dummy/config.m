classdef config < spt.criterion.abstract_config
    % CONFIG - Configuration of dummy nodes
    %
    % See: <a href="matlab:misc.md_help('spt.criterion.dummy.config')">misc.md_help(''spt.criterion.dummy.config'')</a>
   
    
    properties
       
       % Replace this with configuration properties that are relevant to
       % your own criterion
       DummyProp1 = 4; % Default value for DummyProp1
       DummyProp2 = 0; % Default value for DummyProp2
       
    end
    
    % Consistency checks
    % This part is not really necessary, but it is highly recommended that
    % you ensure that the values provided by the user are consistent and
    % valid
    methods
        
        function obj = set.DummyProp1(obj,  value)
           % Here you can check that value is a valid value for DummyProp1 
           % Otherwise you may throw an exception
           import exceptions.InvalidPropValue;
           
           % Imagine that DummyProp1 must be a positive scalar
           if ~isnumeric(value) || numel(value) ~= 1 || value < 0,
               throw(InvalidPropValue('DummyProp1', ...
                   'Must be a positive scalar'));
           end
           
           % value is valid so assign it to the property
           obj.DummyProp1 = value;
           
        end
        
        function obj = set.DummyProp2(obj,  value)
            
            % We could do some consistency checks here as well, but I am
            % lazy
            obj.DummyProp2 = value;
            
        end
             
    end
    
  
    % Constructor (leave this untouched)
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.abstract_config(varargin{:});
                        
        end
        
    end
    
    
    
end