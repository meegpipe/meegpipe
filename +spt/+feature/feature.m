classdef feature < goo.abstract_named_object & goo.hashable
    
    methods (Abstract)
        
        [feature, featName] = extract_feature(obj, sptObj, sptAct, ...
            data, rep, varargin);
        
    end
    
    methods
        
        function code = get_hash_code(obj)
            import datahash.DataHash;
            
            warning('off', 'MATLAB:structOnObject');
            str = struct(obj);
            warning('on', 'MATLAB:structOnObject');
            code = DataHash({str, class(obj)});
            
        end
        
    end
    
end