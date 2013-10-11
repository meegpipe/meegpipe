classdef abstract_named_object < goo.named_object
    
    
    properties
       
        Name;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Name(obj, name)
            import misc.isstring;
            if ~isstring(name),
               error('The Name property must be a string'); 
            end
            
            obj.Name = name;
            
        end
    end
    
    % named_object interface
    methods
        
        function name = get_name(obj)
           
            import misc.strtrim;
            
            if isempty(obj.Name),
                name = class(obj);
                % Remove package info
                if ~isempty(strfind(name, '.')),
                    name = regexprep(name, '^.+\.([^\.]+$)', '$1');
                end                
            else
                name = strtrim(obj.Name);
            end
            name = regexprep(name, '[^\w\.]+', '-');
            
        end
        
        function name = get_full_name(obj)
           
            if isempty(obj.Name),
                name = get_name(obj);
            else
                name = obj.Name;
            end
            
        end
        
        function obj = set_name(obj, name)

            obj.Name = name;
            
        end
        
    end
    
    % constructor
    methods
        
        function obj = abstract_named_object(varargin)            
            import misc.process_arguments;
               
            opt.Name = '';
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Name = opt.Name;
                
            
        end
        
        
    end
    
end