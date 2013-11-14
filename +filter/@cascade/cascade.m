classdef cascade < filter.abstract_dfilt
    
    properties (SetAccess = private, GetAccess = private)
       MDFilt; 
       PersistentMemory;
    end    
    
 
    % Public interface
    % .....................................................................
    properties
       Filter;        
    end
    
    % Consistency checks
    methods
        function obj = set.Filter(obj, value)
            import filter.cascade;
            import exceptions.*;
            
            isValid = iscell(value) && ...
                all(cellfun(@(x) isa(x, 'filter.abstract_dfilt'), value));
            if ~isValid,
                throw(InvalidPropValue('Filter', ...
                    'Must be a cell array of filter.abstract_dfilt objects'));
            end
            obj.Filter = value;
        end
        
        function obj = set.PersistentMemory(obj, value)
            import filter.cascade;
            import exceptions.*;
            if ~numel(value) == 1 || ~islogical(value),
                throw(InvalidPropValue('PersistentMemory', ...
                    'Must be a logical scalar'));
            end
            obj.PersistentMemory = value;
        end
    end
    
    % filter.dfilt interface
    methods
        
        [y, obj] = filter(obj, x, varargin);      
        % required by abstract_dfilt
        H = mdfilt(obj);
        
        function obj = set_persistent(obj, value)
           obj.PersistentMemory = value;
           for i = 1:numel(obj.Filter)
              set_persistent(obj.Filter{i}, value); 
           end          
        end
        
    end
    
    % report.self_reportable interface
    methods         
        [pName, pValue, pDescr]   = report_info(obj);
        % The method below is implemented at abstract_dfilt
        % filename = generate_remark_report(obj, varargin);
    end
    
    
    % Constructor
    methods
        function obj = cascade(varargin)
            if nargin < 1, return; end
            
            obj.Filter = varargin;
        end
    end
    
    
    
    
    
end