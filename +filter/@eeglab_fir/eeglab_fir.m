classdef eeglab_fir < filter.abstract_dfilt
    % EEGLAB_FIR - Wrapper for EEGLAB's firws function
    %
    % obj = eeglab_fir('key', value, ...)
    %
    % where
    %
    % OBJ is an eeglab_fir object
    %
    % ## Accepted key/value pairs:
    %
    %   Fp:           A numeric 1x2 array
    %                 Edges of the frequency pass band (Hz)
    %
    %   Order:        A natural scalar. Default: []
    %                 FIR filter order. If left empty the order of the filter
    %                 will be guessed using EEGLAB's default filter order
    %                 heuristic.
    %
    %   Notch:        A boolean scalar. Default: false
    %                 If set to true, a notch filter instead of a pass band
    %                 filter will be produced.
    %
    %   SamplingRate: A natural scalar. Default: [], unspecified
    %                 If the data sampling rate is not specified, it will
    %                 be derived from property SamplingRate of the filter
    %                 input.
    %
    %   NbFrames:     Number of frames to filter per block. Default: 1000
    %                 See the documentation of EEGLAB's firfilt
    %
    % ## Examples
    %
    % 1) A low pass filter with a cuttof at 20 Hz. Data sampling rate is
    % 500 Hz
    %
    %   obj = eeglab_fir('Fp', [0 20]/(500/2))
    %
    %
    % See also: filter
    
    properties
        
        Fp;
        Order;
        Notch;
        NbFrames;
        SamplingRate;
        
    end
    
    methods (Access = private)
        b = make_b(obj, data);
    end
    
    methods (Access = private, Static)
        boundaries = findboundaries(event);
        data = firfilt(data, b, nFrames, evBndry);
    end
    
    
    methods
        
        function obj = set.Order(obj, value)
            if ~isempty(value) && (value < 2 || mod(value, 2) ~= 0),
                error('Filter order must be a real, even, positive integer');
            end
            obj.Order = value;
        end
        
        % filter.dfilt interface
        function [data, obj] = filter(obj, data, varargin) 
            import misc.eta;
            import physioset.event.class_selector;
            b = make_b(obj, data); 
            v = is_verbose(obj);
            vL = get_verbose_label(obj);
            evBndry = get_event(data);
            if ~isempty(evBndry),
                mySel = class_selector('Class', 'discontinuity');
                evBndry = select(mySel, evBndry);
            end
            if v,
                fprintf([vL ...
                    'Filtering %dx%d data matrix with eeglab_fir ...'], ...
                    size(data,1), size(data,2));
                tinit = tic;
            end
            for i = 1:size(data,1)
                % Weird, but if we don't first get data(i,:) into x, the
                % following command generates a subasgn warning that is not
                % displayed but that screws up some of the tests. This
                % seems to be system specific.
                x = data(i,:);
                data(i,:) = filter.eeglab_fir.firfilt(x, b, obj.NbFrames, evBndry); 
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
        
        function obj = eeglab_fir(varargin)
            import misc.process_arguments;
            import misc.set_properties;
            
            if nargin > 0 && isnumeric(varargin{1}),
                opt.Fp = varargin{1};
                varargin = varargin(2:end);
            else
                opt.Fp = [];
            end
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            opt.Order = [];
            opt.Notch = false;
            opt.NbFrames = 1000;
            opt.SamplingRate = [];
            [~, opt] = process_arguments(opt, varargin);
            
            if isempty(opt.Fp),
                error('Argument Fp needs to be provided');
            end
            
            obj = set_properties(obj, opt);
            
        end
        
        
        
    end
    
    
    
    
    
end