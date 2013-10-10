function cfg = get_runtime_config(obj, forceRead)
% GET_RUNTIME_CONFIG - Get runtime configuration object
%
% cfg = get_runtime_config(obj)
%
% Where
%
% CFG is a mperl.config.inifiles.inifile object.
%
% See also: mperl.config.inifiles.inifile

% Documentation: class_abstract_node_impl.txt
% Description: Get runtime configuration object

import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;

if nargin < 2, 
    forceRead = false;
end

if ~has_runtime_config(obj),
    error('This node does not support runtime configuration');
end

if forceRead || isempty(obj.RunTime_),
    iniFile = catfile(get_full_dir(obj), [get_name(obj) '.ini']);
    warning('off', 'inifile:CreatedIniFile');
    obj.RunTime_ = inifile(iniFile);
    warning('on', 'inifile:CreatedIniFile');
end

cfg = obj.RunTime_;


end