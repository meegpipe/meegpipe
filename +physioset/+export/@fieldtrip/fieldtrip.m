classdef fieldtrip < physioset.export.abstract_physioset_export
    % FIELDTRIP - Exports to EEGLAB .set file
    %
    % See also: physioset.export
    
    properties
        
        BadDataPolicy = 'reject'; % or 'flatten' or 'donothing'
        
    end
    
    methods
        
        function obj = set.BadDataPolicy(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isstring;
            import misc.join;
            
            if isempty(value),
                obj.BadDataPolicy = 'reject';
                return;
            end
            
            validPolicies = {'reject', 'donothing', 'flatten'};
            
            if ~isstring(value) || ...
                    ~ismember(lower(value), lower(validPolicies)),
                throw(InvalidPropValue('BadDataPolicy', ...
                    sprintf('Must be one of the strings: %s', ...
                    join(',', validPolicies))));
            end
            
            obj.BadDataPolicy = value;
            
        end        
       
    end
    
    
    % physioset.export.physioset_export interface
    methods
        physObj = export(obj, ifilename, varargin);
    end
    
    % Constructor
    methods
        
        function obj = fieldtrip(varargin)
            obj = set(obj, varargin{:});
        end
        
    end
    
    
end