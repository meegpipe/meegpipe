classdef fieldtrip_hpfilt < filter.abstract_dfilt
    % FIELDTRIP_HPFILT - Wrapper for Fieldtrip's ft_preproc_highpassfilter
    %
    % See also: filter
    
    properties
        Fc;  % cutoff frequency in Hz   
        SamplingRate;
    end
 
    methods
   
        
        % filter.dfilt interface
        function [data, obj] = filter(obj, data, varargin) 
            import misc.eta;
            import physioset.event.class_selector;
      
            v = is_verbose(obj);
            vL = get_verbose_label(obj);
           
            if v,
                fprintf([vL ...
                    'Filtering %dx%d data matrix with fieldtrip_hpfilt ...'], ...
                    size(data,1), size(data,2));
                tinit = tic;
            end
            for i = 1:size(data,1)
                % Weird, but if we don't first get data(i,:) into x, the
                % following command generates a subasgn warning that is not
                % displayed but that screws up some of the tests. This
                % seems to be system specific.
                x = data(i,:);
                if isa(data, 'physioset.physioset'),
                    sr = data.SamplingRate;
                else
                    sr = obj.SamplingRate;
                end
                data(i,:) = ft_preproc_highpassfilter(x, ...
                    sr, ...
                    obj.Fc); 
                if v,
                    misc.eta(tinit, size(data,1), i);
                end
            end
            if v,
                clear +misc/eta;
                fprintf('\n\n');
            end
        end
        
        function [y, obj] = filtfilt(obj, x, varargin)
           [y, obj] = filter(obj, x, varargin{:}); 
        end
        
        function obj = fieldtrip_hpfilt(varargin)
            import misc.process_arguments;
            import misc.set_properties;
            
            if nargin > 0 && isnumeric(varargin{1})
                varargin = [{'Fc'}, varargin];    
            end
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            opt.Fc = [];    
            opt.SamplingRate = [];
            [~, opt] = process_arguments(opt, varargin);
            
            if isempty(opt.Fc),
                error('Argument Fc needs to be provided');
            end
            
            obj = set_properties(obj, opt);
            
        end
        
        
        
    end
    
    
    
    
    
end