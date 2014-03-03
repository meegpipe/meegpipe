function hs = get_hash_code(obj)

tmpHash = mjava.hash;

tmpHash('Name')         = obj.Name;
tmpHash('Parallelize')  = obj.Parallelize;
tmpHash('Save')         = obj.Save;
tmpHash('Config')       = get_hash_code(get_config(obj));
tmpHash('DataSelector') = struct(obj.DataSelector);

% We do not take into consideration the Report property. The object hash
% should reflect node configuration and runtime parameters but not changes
% in the way results are reported.

% if ~isempty(obj.RunTime_),
%     tmpHash('RunTime_') = get_hash_code(obj.RunTime_);
% end

% if ~isempty(obj.Static_),
%     tmpHash('Static_')  = get_hash_code(obj.Static_);
% end

% We do not take into account Parent_ and NodeIndex_. The hash code should
% identify only local node changes.

hs = get_hash_code(tmpHash);

end
