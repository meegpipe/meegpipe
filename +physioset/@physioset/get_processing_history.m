function history = get_processing_history(obj, idx)

if nargin < 2 || isempty(idx),
    idx = 1:numel(obj.ProcHistory);
end

history = obj.ProcHistory(idx);

if numel(history) == 1,
    history = history{1};
end


end