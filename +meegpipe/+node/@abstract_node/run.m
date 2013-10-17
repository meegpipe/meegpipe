function [data, dataNew] = run(obj, varargin)

import oge.has_oge;
import oge.has_condor;
import goo.pkgisa;
import misc.exception2str;


dataNew = [];

if nargin < 2,
    data = [];
    return;
end

verboseLabel = get_verbose_label(obj);

% Common mistake: user passes multiple files/datasets as a cell array
if nargin == 2 && iscell(varargin{1}) && numel(varargin{1}) == 1,
     varargin = varargin{1};
end

%% Take care of multiple input datasets using recursion
if numel(varargin) > 1,
    
    data = cell(1, numel(varargin));
    if obj.Parallelize && ...
            ((has_condor && strcmp(obj.Queue, 'condor')) || ...
            (has_oge && ~strcmpi(obj.Queue, 'condor')))
        for i = 1:numel(varargin)
            thisObj = clone(obj);
            data{i} = run_oge(thisObj, varargin{i});
        end
        
    else
        
        dataNew = cell(1, numel(varargin));
        for i = 1:numel(varargin)
            thisObj = clone(obj);
            [data{i}, dataNew{i}] = run(thisObj, varargin{i});
        end
        
    end
    
    return;
end

%% Single dataset case
data = varargin{1};

set_tinit(obj, tic);

% Select data to be processed
if pkgisa(data, 'physioset.physioset') && ~isempty(obj.DataSelector),
    
    [oRows, oCols] = size(data);
    
    try
        select(obj.DataSelector, data);
    catch ME
        if strcmp(ME.identifier, 'selector:EmptySelection'),
            warning('abstract_node:EmptySelection', ...
                'The node selects and empty set of data: skipping node');
        else
            rethrow(ME);
        end
    end
    
    if is_verbose(obj) && size(data,1) ~= oRows,
        fprintf([verboseLabel 'Selected %d/%d channels...\n\n'], ...
            size(data,1), oRows);
    end
    if is_verbose(obj) && size(data,2) ~= oCols,
        dataL = size(data,2)/data.SamplingRate;
        fprintf([verboseLabel 'Selected %d (%d%%) seconds...\n\n'], ...
            ceil(dataL), round(100*size(data,2)/oCols));
    end
    
end

initialize(obj, data);

try
    
    data = preprocess(obj, data);
    
    
    % This is implemented by final node classes
    
    if do_reporting(obj) && ~isempty(get_io_report(obj)) && ~ischar(data),
        
        dataIn  = copy(data);
        [data, dataNew] = process(obj, data);
        
    else
        
        dataIn  = data;
        [data, dataNew] = process(obj, data);
        
    end
    
    
    % clear persistent variables in misc.eta
    if is_verbose(obj), clear +misc/eta; end
    
    data = postprocess(obj, data);
    
    % i/o report
    if do_reporting(obj) && ~ischar(dataIn),
        io_report(obj, dataIn, data);
    end
    
    %% save processing history
    if ~isa(obj, 'meegpipe.node.pipeline.pipeline'),
        if ischar(dataIn),
            add_processing_history(data, dataIn);
        end
        if iscell(data),
            cellfun(@(x) isa(add_processing_history(x, obj), 'd'), data);
        else
            add_processing_history(data, obj);
        end
    end
    
    % data is always a physioset, but varargin{1} may not be!
    % some nodes produce a new physioset object (e.g. copy, subset). In those
    % cases you don't want to restore_selection
    if pkgisa(varargin{1}, 'physioset.physioset') && ...
            ~isempty(obj.DataSelector) && ...
            strcmp(get_datafile(data), get_datafile(varargin{1})),
        clear_selection(data);
        % The problem with restore_selection is that we don't know how many
        % cascaded selections were peformed at the input of the node. Using
        % clear_selection is safer and it doesn't really have any major
        % drawback (as far as I know...)
        %restore_selection(data);
    end
    
    finalize(obj, data);
    
catch ME
    % This is useful when running through OGE to find out what happened
    if obj.Parallelize && ~usejava('Desktop'),
        exception2str(ME);
    end
    % Necessary to avoid inconsistent global states
    restore_global_state(obj);
    rethrow(ME);
end

end