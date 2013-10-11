classdef verbose
    % VERBOSE - A simple interface for classes that display status messages
    %
    %
    %
    % See also: misc
    
    % Documentation: class_misc_verbose.txt
    % Description: Interface for classes that display status messages
    
   
    properties (SetAccess = private, GetAccess = private)
        
        Verbose         = true;
        VerboseLabel    = @(obj, meth) ['(' class(obj) ') '];
        VerboseLevel    = 1;
        
    end
    
    methods
        
        function obj = set.Verbose(obj, value)
            
            if numel(value) ~= 1 || ~islogical(value),
                error('Property Verbose must be a logical scalar');
            end
            obj.Verbose = value;
        end
        
        function obj = set.VerboseLabel(obj, value)
            import misc.is_string;
            if ~is_string(value) && ~isa(value, 'function_handle'),
                error('Property VerboseLabel must be a string');
            end
            obj.VerboseLabel = value;
        end
        
    end
    
    % Public interface .....................................................
    
    methods
        
        function bool   = is_verbose(obj)
            import goo.globals;
            bool = globals.get.Verbose & obj.Verbose;
        end
        
        function level  = get_verbose_level(obj)
            level = obj.VerboseLevel;
        end
        
        function label  = get_verbose_label(obj)
            import goo.globals;
            label = globals.get.VerboseLabel;
            if ~isempty(label),
                return;
            elseif ischar(obj.VerboseLabel),
                label = obj.VerboseLabel;           
            elseif isa(obj.VerboseLabel, 'function_handle'),                
                st = dbstack;
                
                if numel(st) > 1,
                    % [className].[methodName]
                    name = st(end).name;
                    name = regexpi(name, '(?<name>[^.]+$)', 'names');
                    label = obj.VerboseLabel(obj, name.name);
                else
                    % [className]
                    label = obj.VerboseLabel(obj,'');
                end
                
            end
        end
        
        function obj    = set_verbose(obj, value)
            obj.Verbose = value;
        end
        
        function obj    = set_verbose_label(obj, value)
            obj.VerboseLabel = value;
        end
        
        function obj    = set_verbose_level(obj, value)
            obj.VerboseLevel = value;
        end
        
    end
    
end