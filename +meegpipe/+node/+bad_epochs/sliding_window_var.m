function obj = sliding_window_var(period, dur, varargin)
% SLIDING_WINDOW_VAR - Reject sliding windows with large variance

warning('sliding_window_var:Obsolete', ...
    ['bad_epochs.sliding_window_var has been deprecated by ' ...
    'bad_epochs.sliding_window and might be removed in future versions']);


obj = meegpipe.node.bad_epochs.sliding_window(period, dur, varargin{:});


end