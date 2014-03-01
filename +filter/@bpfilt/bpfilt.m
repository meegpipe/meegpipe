classdef bpfilt < filter.abstract_dfilt
    % BPFILT - Band-pass digital filter
    %
    % obj = bpfilt('key', value, ...)
    %
    %
    % where
    %
    % OBJ is an bpfilt object
    %
    %
    % ## Most common key/value pairs:
    %
    %       Fp: A numeric 2x1 array.
    %           Normalized 6dB cutoff frequencies of the passband. For
    %           instance, Fp=[0.25 0.50] will use a passband delimited
    %           by the frequencies 0.25*fs/2 and 0.50*fs/2 with fs the
    %           sampling frequency.
    %
    %       PersistentMemory:  A logical scalar. Default: false
    %           Determines whether to save the filter state. If set to true
    %           the filter state will be saved, which is useful when
    %           processing large datasets in data chunks. Note however that
    %           using persistent memory will slow-down considerably the
    %           filtering operation.
    %
    %
    %
    % ## Notes:
    %
    % * Multiple passbands can be specified like this:
    %
    %   obj = bpfilt('fp', [0.1 0.2;0.3 0.4])
    %
    %   which will create a passband filter with pass bands [0.1 0.2] and
    %   [0.3 0.4]
    %
    %
    %
    % See also: lpfilt, hpfilt, sbfilt
    
    properties (SetAccess = private, GetAccess = private)
        MDFilt;     % Equivalent MATLAB dfilt object
    end
  
    properties (SetAccess = private)
        LpFilter;
        HpFilter;
        Fp;
        PersistentMemory;
    end
    
    % filter.dfilt interface
    methods
        [y, obj] = filter(obj, x, varargin);
    end
    
    % report.self_reportable interface
    methods
        [pName, pValue, pDescr]   = report_info(obj);
        % The method below is implemented at abstract_dfilt
        % filename = generate_remark_report(obj, varargin);
    end
    
    % Reimplement the set_verbose method from class goo.verbose
    methods
       
        function obj = set_verbose(obj, value)
           
            obj = set_verbose@goo.verbose(obj, value);
            
            if value, return; end
            
            % This should be done only when setting verbose to false: we
            % dont want the nested filters to produce any output
            for i = 1:numel(obj.LpFilter),
                if isempty(obj.LpFilter{i}), continue; end
                obj.LpFilter{i} = set_verbose(obj.LpFilter{i}, value);
            end
            
            for i = 1:numel(obj.HpFilter),
                if isempty(obj.HpFilter{i}), continue; end
                obj.HpFilter{i} = set_verbose(obj.HpFilter{i}, value);
            end
            
        end
        
    end
    
    % Other public methods
    methods
        y = filtfilt(obj, x, varargin);
        % Required by parent class
        H = mdfilt(obj);
        function obj = set_persistent(obj, value)
            obj.PersistentMemory = value;
            for i = 1:numel(obj.LpFilter),
                if isempty(obj.LpFilter{i}), continue; end
                set_persistent(obj.LpFilter{i}, value);
            end
            for i = 1:numel(obj.HpFilter),
                if isempty(obj.HpFilter{i}), continue; end
                set_persistent(obj.HpFilter{i}, value);
            end
        end
    end
    
    % Constructor
    methods
        function obj = bpfilt(varargin)
            import misc.process_arguments;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            opt.fp                  = [];
            opt.persistentmemory    = false;
            opt.verbose             = true;
            opt.verboselabel        = '(filter.bpfilt) ';
            
            [~, opt] = process_arguments(opt, varargin);
            
            if ~isempty(opt.fp),
                obj.LpFilter = cell(1, size(opt.fp,1));
                obj.HpFilter = cell(1, size(opt.fp,1));
                for filtItr = 1:size(opt.fp,1),
                    if opt.fp(filtItr, 2) < 1,
                        obj.LpFilter{filtItr} = ...
                            filter.lpfilt(...
                            'fc',               opt.fp(filtItr, 2), ...
                            'PersistentMemory', opt.persistentmemory, ...
                            'Verbose',          opt.verbose, ...
                            'VerboseLabel',     opt.verboselabel);
                    end
                    if opt.fp(filtItr, 1) > 0,
                        obj.HpFilter{filtItr} = ...
                            filter.hpfilt(...
                            'fc',               opt.fp(filtItr, 1), ...
                            'PersistentMemory', opt.persistentmemory, ...
                            'Verbose',          opt.verbose, ...
                            'VerboseLabel',     opt.verboselabel);
                    end
                end
            end
            obj.Fp = opt.fp;
            obj = set_persistent(obj, opt.persistentmemory);
            
            % Now set the verbose property, but not for nested filters
            obj = set_verbose(obj, opt.verbose);
            obj = set_verbose_label(obj, opt.verboselabel);
        end
        
    end
    
    
end