function obj = UnstableModel(msg)

if nargin < 1 || isempty(msg),
    msg = '??';
end

[st, i] = dbstack;

if numel(st) < 2,
    name = 'Base';
else
    st   = st(i+1);
    name = strrep(st.name, '.', ':');
end

obj = MException([name ':UnstableModel'], ...
    'Unstable VAR model: %s', msg);

end
