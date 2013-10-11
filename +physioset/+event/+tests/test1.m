function [status, MEh] = test1()
% TEST1 - Tests basic functionality of package event

import physioset.event.*;
import physioset.event.std.*;
import test.simple.*;

MEh     = [];

initialize(18);

%% default constructors
try
    
    name = 'default constructors';
    event;
    latency_selector;
    class_selector;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% array construction using cat
try
    
    name = 'array construction using cat';
    
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = [event(1000, keyVals{:}), ...
        analysis_window(1000, keyVals{:}), ...
        discontinuity(1000, keyVals{:}), ...
        epoch_begin(1000, keyVals{:}), ...
        file_begin(1000, keyVals{:}), ...
        trial_begin(1000, keyVals{:})];
 
    ok(strcmp(get(ev(1), 'Type'), 'QRS'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% array construction using preallocation
try
    
    name = 'array construction using preallocation';
    
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:});
    ev(10) = analysis_window(1000, keyVals{:});    
    ev(20) = discontinuity(1000, keyVals{:});
    ev(30) = epoch_begin(1000, keyVals{:});
    ev(40) = file_begin(1000, keyVals{:});
    ev(50) = trial_begin(1000, keyVals{:});
    
    ok(isa(ev(30), 'epoch_begin'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Get properties from array
try
    
    name = 'get properties from array';
    
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:});
    
    sample = get(ev, 'Sample');
    type   = unique(get(ev, 'Type'));
    
    ok(...
        all(sample == 1:100) && ...
        numel(type) == 1 && strcmp(type{1}, 'QRS'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% set array properties
try
    
    name = 'set array properties';
    
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:});
    
    ev = set(ev, 'Type', 'funny', 'Offset', 10, 'Sample', 20);
    
    type   = unique(get(ev, 'Type'));
    offset = unique(get(ev, 'Offset'));
    sample = unique(get(ev, 'Sample'));
    
    ok(strcmp(type, 'funny') && offset == 10 && sample == 20, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% set heterogeneous array properties
try
    
    name = 'set heterogeneous array properties';
  
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:});
    
    types = num2cell(1:100);
    types = cellfun(@(x) num2str(x), types, 'UniformOutput', false);
    
    ev = set(ev, 'Sample', 201:300, 'Type', types);
    
    [types, ~, iTypes]   = unique(get(ev, 'Type'));
    [sample, ~, iSample] = unique(get(ev, 'Sample'));
    types  = types(iTypes);
    sample = sample(iSample);
   
    ok(numel(types) == 100 && strcmp(types{30}, '30') && ...
        numel(sample) == 100 && sample(2) == 202, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% method eq
try
    
    name = 'methods eq/neq';
   
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:5, keyVals{:});    
   
    ok(ev(1) == ev(3) && ev(2) ~= event, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% method resample
try
    
    name = 'method resample';
   
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:}); 
    
    ev2 = resample(ev, 1, 10);
    
    ev3 = resample(ev, 10, 5);
   
    ok(...
        get(ev2(11), 'Sample') ==  2 && get(ev2(12), 'Duration') == 10 && ...
        get(ev3(1), 'Sample') == 2 && get(ev3(100), 'Duration') == 200, ...
        name);    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% method shift
try
    
    name = 'method resample';
   
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:}); 
    
    ev2 = shift(ev,30);
   
    ok(get(ev2(1), 'Sample') ==  31 && get(ev2(2), 'Sample') == 32, ...
        name);    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% conversion to struct
try
    
    name = 'conversion to struct';
   
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:}); 
    
    str = struct(ev);
   
    ok(...
        isstruct(str) && numel(str) == 100 && ...
        str(20).sample == get(ev(20), 'Sample'), ...
        name);    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% conversion to/from EEGLAB struct
try
    
    name = 'conversion to/from EEGLAB struct';
   
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:}); 
   
    ev(5) = set(ev(5), 'Offset', -10);
    
    ev(5) = set_meta(ev(5), 'MetaInfo', 10, 'Position', 'top');
    
    eStr = eeglab(ev);
    
    ev2  = event.from_eeglab(eStr);
    
    eStr2 = eeglab(ev2);
   
    ok(...
        eStr2(5).meta.MetaInfo == eStr(5).meta.MetaInfo, ...
        name);    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% conversion to/from Fieldtrip struct
try
    
    name = 'conversion to/from Fieldtrip struct';
   
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:}); 
    
    ev(5) = set_meta(ev(5), 'MetaInfo', 10, 'position', 'top');
    
    fStr = fieldtrip(ev);
    
    ev2  = event.from_fieldtrip(fStr);
    
    fStr2 = fieldtrip(ev2);
   
    ok(...
        fStr2(5).sample == 5 && strcmp(fStr2(5).type, 'QRS'), ...
        name);    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% method sort
try
    
    name = 'method sort';
   
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:}); 
    
    ev(4) = set(ev(4), 'Sample', 1000, 'Type', 'LastEvent');
    
    evSorted = sort(ev);
   
    ok(...
        strcmp(get(evSorted(end), 'Type'), 'LastEvent'), ...
        name);    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% latency_selector
try
    
    name = 'latency_selector';
   
    keyVals = {'Type', 'QRS', 'Offset', -40, 'Duration', 100};
    
    ev = event(1:100, keyVals{:}); 
    
    selEv = select(latency_selector(1, [31 40;61 70]), ev);
 
    ok(...
        numel(selEv) == 20 && get(selEv(1), 'Sample') == 31, ...
        name);    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% class_selector (event class)
try
    
    name = 'class_selector (event class)';
   
     ev = [event(1000), ...
        analysis_window(2000), ...
        discontinuity(3000), ...
        epoch_begin(4000), ...
        file_begin(5000), ...
        trial_begin(6000)];
    
    sel = select(class_selector('Class', 'analysis_window'), ev);
    
    evSelector = class_selector('Class', {'epoch_begin', 'trial_begin'});
    sel2 = select(evSelector, ev);
 
    ok(...
        numel(sel) == 1 && isa(sel, 'physioset.event.std.analysis_window') && ...
        numel(sel2) == 2 && isa(sel2(1), 'physioset.event.std.epoch_begin'), ...
        name);    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% class_selector (event type)
try
    
    name = 'class_selector (event type)';
    
    ev = [event(1000, 'Type', 'type1'), ...
        analysis_window(2000, 'Type', 'type2'), ...
        discontinuity(3000, 'Type', 'other'), ...
        event(4000, 'Type', 'type3'), ...
        event(5000, 'Type', 'other') ...
        event(5000, 'Type', 'othertype') ...
        trial_begin(6000)];
    
    sel = select(class_selector('Type', 'type\d'), ev);
    
    evSelector = class_selector('Type', {'other$', 'type\d'});
    sel2 = select(evSelector, ev);
    
    ok(numel(sel) == 3 && numel(sel2) == 5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Select nearest neighbors
try
    name = 'select NN events';
    
    ev1 = event(1:100:1000);
    ev2 = event(40:100:1000);
    
    ev = nn_all(ev1, ev2);
    
    ok(numel(ev) == numel(ev2) & ...
        all(get_sample(ev2) == get_sample(ev)), name);
        
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Set/get meta-properties
try
    name = 'set/get meta-properties';
    
    ev = event(1:100:1000);
    
    ev(2) = set_meta(ev(2), 'testprop', 10);
    ev(3) = set_meta(ev(2), 'testprop', 20);
    
    metaProp = get_meta(ev, 'testprop');
    ok(numel(metaProp) == 10 & metaProp{2} == 10, name);
        
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end




%% Testing summary
status = finalize();