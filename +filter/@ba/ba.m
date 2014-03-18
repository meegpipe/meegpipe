classdef ba < ...
        filter.dfilt             & ... 
        goo.verbose              & ... 
        goo.abstract_setget      & ... 
        goo.abstract_named_object
    % ADAPTFILT - A wrapper for MATLAB's adaptfilt classes
    %
    % ## Usage synopsis:
    %
    % % Build a moving average filter of order 10
    % obj = filter.ba(ones(1,10)/10, 1)
    % y = filter(obj, x, d);
    %
    % Where
    %
    % OBJ is a filter.dfilt object
    %
    % X is the input to the filter (a KxM numeric matrix).
    %
    %
    % See also: filter
    
    properties (SetAccess = private, GetAccess = public)
        
        B;
        A;
        
    end    
   
    % filter.dfilt interface
    methods
        [y, obj] = filter(obj, x, d, varargin);
        y = filtfilt(obj, x, varargin);
    end
    
    
    % Constructor
    methods
        
        function obj = ba(b, a, varargin)
            
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            opt.Name = 'ba';
            opt.Verbose = true;           
            [~, opt] = process_arguments(opt, varargin);
         
            obj.A = a;
            obj.B = b;
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
    
    
end