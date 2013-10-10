function initialize(obj, data)
% INITIALIZE - Initialize processing node
%
% initialize(obj)
%
%
% See also: run, finalize, preprocess, postprocess

import meegpipe.node.globals;
import pset.session;
import exceptions.*;
import mperl.file.spec.catfile;
import mperl.file.spec.rel2abs;
import safefid.safefid;
import misc.any2str;

%% Set the global Verbose mode to match that of this node
verboseLabel                    = get_verbose_label(obj);
obj.SuperGlobals_.VerboseLabel  = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

verbose                         = is_verbose(obj);
obj.SuperGlobals_.Verbose       = goo.globals.get.Verbose;
goo.globals.set('Verbose', verbose);

%% Set the global GenerateReport variable
obj.Globals_.GenerateReport = globals.get.GenerateReport;
globals.set('GenerateReport', do_reporting(obj));

%% Node root directory
obj.RootDir_ = get_full_dir(obj, data);
obj.SaveDir_ = obj.RootDir_;

if isempty(get_parent(obj)),
    obj.VersionFile_ = catfile(obj.RootDir_, 'submodule.version');
end

if ~exist(obj.RootDir_, 'dir'),
    [success, msg] = mkdir(obj.RootDir_);
    if ~success,
        throw(FailedSystemCall('mkdir', msg));
    end
end

% Create a session to store all temporary files
if isempty(get_parent(obj)),   
    session.subsession(get_tempdir(obj), 'Force', true);        
    globals.set('ResetNodes', false);
end

%% Save node object, node input, and meegpipe version
if isempty(get_parent(obj))
    
    fName = catfile(obj.RootDir_, 'node.mat');
    builtin('save', fName, 'obj');
    obj.SavedNode_ = fName;
    
    fName = catfile(obj.RootDir_, 'input.mat');
    builtin('save', fName, 'data');
    obj.SavedInput_ = fName;
    
    % Keep a backup of the previous submodule revisions, just in case
    if exist(obj.VersionFile_, 'file'),
        [path, name, ext] = fileparts(obj.VersionFile_);
        copyfile(...
            obj.VersionFile_, ...
            catfile(path, [name '_' datestr(now, 'yymmddHHMMSS') ext]), ...
            'f');
    end
    
    fid = safefid.fopen(obj.VersionFile_, 'w');
    dirName = rel2abs([meegpipe.root_path filesep '..']);
    [modRev, modList] = submodule_revision(dirName);
    fprintf(fid, 'modList=%s\n', any2str(modList, Inf));
    fprintf(fid, 'modRev=%s\n', any2str(modRev, Inf));

end


%% Should the runtime params be invalidated?
obj.RunTime_ = get_runtime_config(obj, true);

if globals.get.ResetNodes || has_changed_config(obj) 
   
    % Following nodes' runtime params are also invalid
    globals.set('ResetNodes', true);    
  
    clear_runtime(obj);
   
end

%% Store node configuration hash
set_static(obj, 'hash', 'config', get_hash_code(get_config(obj)));


%% Initialize node report

% Note: The report needs to be initialized even if reporting if OFF.
% Otherwise things will break if a node of a pipeline (whose reporting is
% OFF) has reporting set to ON.
nodeReport = report.node.node(obj);

set_report(obj, nodeReport);

rep = get_report(obj);

initialize(rep);


end