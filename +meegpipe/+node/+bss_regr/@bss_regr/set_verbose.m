function obj = set_verbose(obj, value, varargin)

obj = set_verbose@goo.verbose_handle(obj, value, varargin{:});

cfg = get_config(obj);

if ~isempty(cfg.PCA),
    cfg.PCA = set_verbose(cfg.PCA, value, varargin{:});
end

if ~isempty(cfg.BSS),
    cfg.BSS = set_verbose(cfg.BSS, value, varargin{:});
end

if ~isempty(cfg.Criterion),
    cfg.Criterion = set_verbose(cfg.Criterion, value, varargin{:});
end

if ~isempty(cfg.Filter),
    cfg.Filter = set_verbose(cfg.Filter, value, varargin{:});
end

end