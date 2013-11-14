function obj = NotImplemented(msg)

if nargin < 1 || isempty(msg),
    msg = '??';
end

[st, i] = dbstack;

st   = st(i+1);
name = strrep(st.name, '.', ':');

obj = MException([name ':NotImplemented'], ...
    'Not implemented feature: %s', msg);

end
