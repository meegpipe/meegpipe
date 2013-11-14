function rankValue = compute_rank(obj, ~, tSeries, sr, ~, ~, raw, varargin)

import misc.fd;

if nargin < 4 || isempty(sr),
    if nargin > 7 && ~isempty(raw) && pkgisa(raw, 'physioset'),
        sr = raw.SamplingRate;
    else
        error('tfd:UnknownSamplingRate', ...
            'The data sampling rate must be provided');
    end
end
    

cfg.method = get_config(obj, 'Algorithm');
cfg.wl     = get_config(obj, 'WindowLength');
cfg.ws     = get_config(obj, 'WindowShift');

if isa(cfg.wl, 'function_handle'),
    cfg.wl = cfg.wl(sr);
end

if isa(cfg.ws, 'function_handle'),
    cfg.ws = cfg.ws(sr);
end

rankValue = fd(tSeries', cfg);
rankValue = rankValue-min(rankValue);
rankValue = rankValue./max(rankValue);
rankValue = 1-rankValue; % low FDs lead to higher ranks

end