classdef hpfilt < filter.abstract_dfilt
    % HPFILT - High-pass digital filter
    %
    % obj = hpfilt('key', value, ...)
    %
    %
    % where
    %
    % OBJ is an hpfilt object
    %
    %
    % ## Most common key/value pairs:
    %
    %       Fc: A numeric scalar.
    %           The normalized 6dB cutoff frequency
    %
    %       PersistentMemory:  A logical scalar. Default: false
    %           Determines whether to save the filter state. If set to true
    %           the filter state will be saved, which is useful when
    %           processing large datasets in data chunks. Note however that
    %           using persistent memory will slow-down considerably the
    %           filtering operation.
    %
    %
    % See also: lpfilt, bpfilt, sbfilt
    
    % Documentation: filter_hpfilt_class.txt
    % Description: Class definition
    
    % Public interface ....................................................
    properties (SetAccess = private)
        Specs;
        H;
        Order;
        Delay;
        DesignMethod;
        PersistentMemory;
    end
    
    % Consistency checks
    methods
        function obj = set.PersistentMemory(obj, value)
            import filter.hpfilt;
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
    end
    
    % report.self_reportable interface
    methods
        [pName, pValue, pDescr]   = report_info(obj);
        % The method below is implemented at abstract_dfilt
        % filename = generate_remark_report(obj, varargin);
    end
    
    methods
        y = filtfilt(obj, x, varargin);
        % Required by parent class
        function H = mdfilt(obj)
            H = obj.H;
        end
        function obj = set_persistent(obj, value)
            obj.PersistentMemory = value;
        end
    end
    
    % Constructor
    methods
        function obj = hpfilt(varargin)
            import misc.process_arguments;
            import filter.abstract_dfilt;
            import exceptions.*;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            % default options
            opt.ap                  = filter.globals.evaluate.Ap;
            opt.ast                 = filter.globals.evaluate.Ast;
            f3db                    = [];
            opt.fc                  = [];
            opt.fp                  = [];
            opt.fst                 = [];
            opt.n                   = [];
            opt.designmethod        = filter.globals.evaluate.DesignMethod;
            opt.persistentmemory    = false;
            
            % process varargin
            [~, opt] = process_arguments(opt, varargin);
            
            % Filter specification object
            if isempty(opt.fp) || isempty(opt.fst),
                % If the specification is not complete, try to guess
                if ~isempty(opt.fc),
                    if ~isempty(f3db) || ~isempty(opt.fp) || ...
                            ~isempty(opt.fst),
                        throw(Inconsistent('Invalid filter specification'));
                    end
                    if isempty(opt.fp),     opt.fp = 1.05*opt.fc; end
                    if isempty(opt.fst),    opt.fst = 0.9*opt.fc; end
                    if isempty(opt.n),
                        [opt.n, opt.fp, opt.fst, opt.ap, opt.ast] = ...
                            abstract_dfilt.filt_ord(opt.designmethod, ...
                            opt.fp, opt.fst, opt.ap, opt.ast, 'high');
                    end
                    
                elseif ~isempty(f3db),
                    if ~isempty(opt.fc) || ~isempty(opt.fp) || ~isempty(opt.fst),
                        throw(Inconsistent('Invalid filter specification'));
                    end
                    if isempty(opt.fp), opt.fp = 1.03*f3db; end
                    if isempty(opt.fst), opt.fst = 0.8*f3db; end
                    if isempty(opt.n),
                        [opt.n, opt.fp, opt.fst, opt.ap, opt.ast] = ...
                            abstract_dfilt.filt_ord(opt.designmethod, ...
                            opt.fp, opt.fst, opt.ap, opt.ast, 'high');
                    end
                    
                elseif ~isempty(opt.fp),
                    if ~isempty(opt.fc) || ~isempty(f3db) || ~isempty(opt.fst),
                        throw(Inconsistent('Invalid filter specification'));
                    end
                    if isempty(opt.fst), opt.fst = 0.75*opt.fp; end
                    if isempty(opt.n),
                        [opt.n, opt.fp, opt.fst, opt.ap, opt.ast] = ...
                            abstract_dfilt.filt_ord(opt.designmethod, ...
                            opt.fp, opt.fst, opt.ap, opt.ast, 'high');
                    end
                    
                elseif ~isempty(opt.fst),
                    if ~isempty(opt.fc) || ~isempty(opt.fp) || ~isempty(f3db),
                        throw(Inconsistent('Invalid filter specification'));
                    end
                    if isempty(opt.fp), opt.fp = 1.25*opt.fst; end
                    if isempty(opt.n),
                        [opt.n, opt.fp, opt.fst, opt.ap, opt.ast] = ...
                            abstract_dfilt.filt_ord(opt.designmethod, ...
                            opt.fp, opt.fst, opt.ap, opt.ast, 'high');
                    end
                else
                    throw(Inconsistent('Invalid filter specification'));
                end
            elseif isempty(opt.n),
                [opt.n, opt.fp, opt.fst, opt.ap, opt.ast] = ...
                    abstract_dfilt.filt_ord(opt.designmethod, opt.fp, ...
                    opt.fst, opt.ap, opt.ast, 'high');
            end
            obj.Order = opt.n;
            obj.Specs = fdesign.highpass('Fst,Fp,Ast,Ap', ...
                opt.fst, opt.fp, opt.ast, opt.ap);
            
            % Design filter
            obj.DesignMethod = opt.designmethod;
            if ismember(opt.designmethod, designmethods(obj.Specs)),
                obj.H = design(obj.Specs, opt.designmethod);
            else
                obj.H = design(obj.Specs);
            end
            
            % Force the filter to store its state?
            obj.H.PersistentMemory = opt.persistentmemory;
            obj.PersistentMemory = opt.persistentmemory;
            
            % Find out the average group delay for the passband
            [Gd,W] = grpdelay(obj.H, 256);
            obj.Delay = round(mean(Gd(W<opt.fp*pi)));
        end
    end
end