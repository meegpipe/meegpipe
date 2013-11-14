classdef adaptfilt < ...
        filter.rfilt                & ...   
        goo.verbose                 & ...    
        goo.abstract_setget         & ...    
        goo.abstract_named_object  
    % ADAPTFILT - A wrapper for MATLAB's adaptfilt classes
    %
    % ## Usage synopsis:
    %
    % import filter.*;
    % obj = adaptfilt.rls(l, lambda, ...)
    % y = filter(obj, x, d);
    %
    % Where
    %
    % OBJ is a filter.adaptfilt object
    %
    % X is the input to the filter (a KxM numeric matrix).
    %
    % D is the desired filter output (a NxM numeric matrix).
    %
    % L, LAMBDA, etc are the input arguments accepted by MATLAB's DSP
    % System toolbox component adaptfilt.rls.
    %
    %
    % See also: adaptfilt
    
    properties (SetAccess = private, GetAccess = private)
        
        Filter;
        MinCorr = 0.25;
        
    end
    
    % consistency checks
    methods
       
        function obj = set.Filter(obj, value)
           
            import eegpipe.exceptions.*;
            if isempty(value), 
                throw(InvalidPropValue('Filter', ...
                    'Must be non-empty'));
            end
            
            if numel(value) ~= 1 || ...
                    isempty(regexp(class(value), '^adaptfilt.', 'once')),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.rfilt object'));
            end
            obj.Filter = value;
            
        end
        
    end
    
     % filter.dfilt interface
    methods
        [y, obj] = filter(obj, x, d, varargin);
    end
    
    
    % Constructor
    methods
        
        function obj = adaptfilt(filtObj, varargin)
           
            import misc.process_arguments;
            
            if nargin < 1, return; end
           
            opt.Name = 'adaptfilt';
            opt.Verbose = true;
            opt.MinCorr = 0.25;
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Filter = filtObj;
            obj.MinCorr = opt.MinCorr;
            
            obj = set_name(obj, class(obj.Filter));
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
   
    
end