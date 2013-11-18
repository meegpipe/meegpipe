function [dataIn, dataNew] = process(obj, dataIn, varargin)


import misc.eta;
import goo.globals;
import misc.signal2hankel;
import meegpipe.node.bss_regr.bss_regr;

verbose          = is_verbose(obj);
verboseLabel     = get_verbose_label(obj);
origVerboseLabel = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

dataNew = [];

%% Configuration options
regrFilter = get_config(obj, 'RegrFilter');
pca        = get_config(obj, 'PCA');
bss        = get_config(obj, 'BSS');
chopSel    = get_config(obj, 'ChopSelector');
criterion  = get_config(obj, 'Criterion');
overlap    = get_config(obj, 'Overlap');
fixNbICs   = get_config(obj, 'FixNbICs');
reject     = get_config(obj, 'Reject');
filtObj    = get_config(obj, 'Filter');

if isa(filtObj, 'function_handle'),
    filtObj = filtObj(dataIn.SamplingRate);
end

sr = dataIn.SamplingRate;

%% Filtering + PCA + chopping
center(dataIn);

% PCA
pca = learn(pca, dataIn);

% Careful here: dataCopy and pcs are aliases of the same thing!
pcs = proj(pca, copy(dataIn));

% Find chop boundaries

bndy = [1 nb_pnt(dataIn)+1];

if ~isempty(chopSel),
    chopEvents = select(chopSel, get_event(dataIn));
    if ~isempty(chopEvents),
        evSample = get(chopEvents, 'Sample');
        bndy = unique([1; evSample(:);  nb_pnt(dataIn)+1]);
    end
end


%% Blind source separation

% Random seed for BSS algorithms that require it
seed = get_runtime(obj, 'bss', 'seed');
init = get_runtime(obj, 'bss', 'init');

bss  = set_seed(bss, seed);
bss  = set_init(bss, init);

set_runtime(obj, 'bss', 'seed', get_seed(bss));
set_runtime(obj, 'bss', 'init', get_init(bss, pca.DimOut));

% All projection matrices
pW = nan(pca.DimOut, pca.DimOut, numel(bndy)-1);
pA = nan(pca.DimOut, pca.DimOut, numel(bndy)-1);

% All sorted indices
sI = nan(pca.DimOut, numel(bndy)-1);
isSel = false(pca.DimOut, numel(bndy)-1);
overriden = false(1, numel(bndy) -1);

% Number of selected components
nC = nan(1, numel(bndy)-1);

rep = get_report(obj);
print_title(rep, 'Data processing report', get_level(rep) + 1);

print_title(rep, 'Principal Component Analysis', ...
    get_level(rep) + 2);

% Print a PCA report
if do_reporting(obj),
    fprintf(rep, pca);
else
    fprintf(rep, pca, [], false);
end

print_paragraph(rep, 'Selected %d principal components', pca.DimOut);

print_title(rep, 'Blind Source Separation', ...
    get_level(rep) + 2);


tinit1 = tic;
bssH = cell(1, numel(bndy)-1);
winRep = cell(1, numel(bndy)-1);
for segItr = 1:numel(bndy)-1
    
    if verbose,
        
        fprintf( [verboseLabel ...
            'Learning PCA/BSS basis for epoch %d/%d...\n\n'], ...
            segItr, numel(bndy)-1);
        origVerboseLabel = globals.get.VerboseLabel;
        globals.set('VerboseLabel', ['\t' origVerboseLabel]);
        
    end
    
    winRep{segItr} = childof(report.generic.generic, rep);
    
    % Select the current analysis window
    select(dataIn, [], bndy(segItr):bndy(segItr+1)-1);
    
    % If this is not the first window, try to get a similar projection as
    % in previous windows by sending to ICA some data from the previous
    % window
    [prevPcs, nextPcs] = neighbors(pcs, bndy, segItr, overlap);
    
    thisPcs   = pcs(:, bndy(segItr):bndy(segItr+1)-1);
    
    %% BSS
    if segItr > 1,
        
        pMp = squeeze(pW(:,:,segItr-1));
        % Initialize at the point where we left it in the prev. window
        bss = learn(bss, pMp*[prevPcs thisPcs nextPcs]);
        bss = rmap(bss, pMp);
        bss = match_sources(bss, squeeze(pinv(pW(:, : , segItr-1))));
        
    else
        
        bss = learn(bss, [prevPcs thisPcs nextPcs]);
        
    end
    
    bssH{segItr} = bss;
    
    pW(:, :, segItr) = projmat(bss);
    pA(:, :, segItr) = bprojmat(bss);
    ics = proj(bss, thisPcs);
    
    % Events within the analysis window (might be needed by the criterion)
    %bssEmbedded = embed_pca(bss, pca);
    bssEmbedded = cascade(pca, bss);
    if ~isempty(dataIn.Event),
        events = get_event(dataIn); % Takes care of selections
    else
        events = [];
    end
    
    % Automatic ranking and selection of components
    [selected, rankIdx] = select(criterion, bssEmbedded, ics(:,:), dataIn, ...
        winRep{segItr});
    
    [rankIdx, sortedIdx] = sort(rankIdx, 'descend');
    
    % See whether user has manually overriden the selection
    section    = ['window ' num2str(segItr)];
    runtimeSel = get_runtime(obj, section, 'selection', true);
    if iscell(runtimeSel),
        runtimeSel = cell2mat(runtimeSel);
    end
    
    if isnumeric(runtimeSel) && numel(runtimeSel) == 1 && isnan(runtimeSel),
        % If the user wants the manual selection of components to be
        % ignored she can do either of three things:
        %
        % - Delete the .ini file: all windows' selections will be reset
        % - Delete the "selection" parameter in the corresp. window
        % - Delete the correspoding [window X] section completely.
        ignoreRunTime = true;
    else
        % selection=something
        ignoreRunTime = false;
        overriden(segItr) = ~isempty(setxor(runtimeSel, find(selected)));
    end
    
    if ~ignoreRunTime && overriden(segItr)
        runtimeSel = intersect(runtimeSel, 1:size(ics,1));
        if verbose,
            fprintf([ get_verbose_label(obj) ...
                'User selection overrides automatic selection ' ...
                '(%d selected)...\n\n'], numel(runtimeSel));
        end
    end
    section = sprintf('window %d', segItr);
    
    if ~ignoreRunTime && overriden(segItr),
        selected = false(size(selected));
        selected(sortedIdx(runtimeSel)) = true;
    end
    
    sI(1:numel(sortedIdx), segItr) = sortedIdx(:);
    nC(segItr) = numel(find(selected));
    isSel(:, segItr) = selected;
    
    % Generate report
    title  =  sprintf('Window %d/%d: %d-%d secs', segItr, ...
        numel(bndy)-1, floor(bndy(segItr)/sr), ...
        ceil(bndy(segItr+1)/sr));
    set_title(winRep{segItr}, title);
    
    initialize(winRep{segItr});
    
    if do_reporting(obj),
        
        % Print a link to the window report
        print_link2report(rep, winRep{segItr});
        
        thisICs = import(physioset.import.matrix(sr), ics(sortedIdx, :));
        
        set_name(thisICs, [get_name(bss), ' activations']);
        
        add_event(thisICs, events);
        
        bss_regr.generate_rank_report(winRep{segItr}, criterion, rankIdx, ...
            nC(segItr));
        
    end
    
    % Remove analysis window selection
    restore_selection(dataIn);
    
    if verbose,
        
        verboseLabel = origVerboseLabel;
        globals.set('VerboseLabel', verboseLabel);
        
        fprintf( ['\n\n' verboseLabel, ...
            'done learning BSS basis for epoch %d/%d...'], segItr, ...
            numel(bndy)-1);
        
        eta(tinit1, numel(bndy)-1, segItr, 'remaintime', true);
        
        fprintf('\n\n');
        
    end
    
end

% Fix the number of ICs across windows, if requested by user
if ~isempty(fixNbICs)
    if isa(fixNbICs, 'function_handle'),
        nCF = fixNbICs(nC, pca.DimOut);
    else
        nCF = fixNbICs;
    end
    nC = repmat(nCF, 1, numel(nC));
end

% Save diagnostic information
set_diagnostics(obj, sI, isSel, nC, pW, pA, pca);

clear misc.eta;

%% Denoise by rejecting or accepting the relevant components
tinit2 = tic;

for segItr = 1:numel(bndy)-1
    
    if verbose,
        
        fprintf( [verboseLabel, ...
            'Denoising epoch %d/%d...\n\n'], segItr, ...
            numel(bndy)-1);
        
        origVerboseLabel = globals.get.VerboseLabel;
        globals.set('VerboseLabel', ['\t' origVerboseLabel]);
        
    end
    
    % Data selection
    thisPcs   = pcs(:, bndy(segItr):bndy(segItr+1)-1);
    select(dataIn, [], bndy(segItr):bndy(segItr+1)-1);
    
    % What components were selected for rejection/acceptance
    sortedIdx = sI(1:end, segItr);
    if overriden(segItr),
        selected = isSel(:, segItr);
    else
        selected = false(1, numel(sortedIdx));
        selected(sortedIdx(1:nC(segItr))) = true;
    end
    
    % Write selection .ini file
    idxSel  = find(selected(sortedIdx));
    selArg  = num2cell(idxSel);
    set_runtime(obj, section, 'selection', selArg{:});
    
    ics = proj(bssH{segItr}, thisPcs);
    
    %% Print summary information on selected components:
    if verbose
        fprintf(['\t' verboseLabel, 'Generating SPCs selection report...\n\n']);
    end
    
    selectedSorted = selected(sortedIdx);
    
    if numel(bndy) < 3
        if ~any(selected),
            msg = 'No components';
        else
            msg = ['Component(s) __[', ...
                regexprep(num2str(find(selectedSorted(:)')), ...
                '\s+', ', ') ']__'];
        end
        
        if overriden(segItr),
            warnMsg = 'This is a user-defined selection.';
        else
            warnMsg = [];
        end
        
        warnMsg = [warnMsg, ' Note that this ' ...
            ' selection may differ from the selection that the automatic ' ...
            ' criterion suggests, either because of the user having ' ...
            ' overriden the selection, or because property FixNbICs is' ...
            ' in effect.']; %#ok<AGROW>
        
        if reject,
            print_paragraph(rep, [msg ...
                ' were __REJECTED__ in this analysis window. ' warnMsg]);
        else
            print_paragraph(rep, [msg ...
                ' were __ACCEPTED__ in this analysis window. ' warnMsg]);
        end
    end
    
    % Generate report for this analysis window
    if do_reporting(obj),
        
        thisICs = import(physioset.import.matrix(sr), ics(sortedIdx, :));
        
        set_name(thisICs, [get_name(bss), ' activations']);
        
        thisEv = get_event(dataIn);
        if ~isempty(thisEv),
            thisEv = shift(thisEv, bndy(segItr)-1);
            add_event(thisICs, thisEv);
        end
        
        bss_regr.generate_win_report(winRep{segItr}, ...
            sensors(dataIn), ...
            reorder(bssEmbedded, sortedIdx), ...
            thisICs, ...
            selectedSorted, ...
            reject);
        
    end
    
    if nC(segItr) < 1 && ~reject,
        % We select the empty set
        dataIn(:,:) = 0;
    elseif nC(segItr) > 0,
        
        bssH{segItr} = deselect(bssH{segItr}, 'all');
        bssH{segItr} = select(bssH{segItr}, find(selected));
        
        ics = proj(bssH{segItr}, thisPcs);
        
        [~, loc] = ismember(find(selected), sortedIdx);
        [~, idx] = sort(loc, 'ascend');
        ics = ics(idx,:);
        
        if ~isempty(filtObj),
            
            if do_reporting(obj),
                myImporter = physioset.import.matrix(...
                    'SamplingRate', dataIn.SamplingRate);
                icsIn = import(myImporter, ics);
            end
            ics = filtfilt(filtObj, ics);
            if do_reporting(obj),
                icsOut = import(myImporter, ics);
                bss_regr.generate_filt_report(winRep{segItr}, ...
                    icsIn, icsOut);
            end
            
        end
        
        ics(idx,:) = ics(:,:);
        pcsNoise = bproj(bssH{segItr}, ics);
        
        if reject,          
            thisData = dataIn(:,:) - bproj(pca, pcsNoise);         
        else
            thisData = bproj(pca, pcsNoise);
        end
        
        % Remove residual noise using multiple-lag regression
        if reject && ~isempty(regrFilter),
            dataIn(:,:) = filter(regrFilter, thisData, ics);
        else
            dataIn(:, :) = thisData;
        end
        
    end
    
    % Remove analysis window selection
    restore_selection(dataIn);
    
    
    if verbose,
        
        verboseLabel = origVerboseLabel;
        globals.set('VerboseLabel', verboseLabel);
        
        fprintf( [verboseLabel, ...
            'done denoising epoch %d/%d...'], segItr, ...
            numel(bndy)-1);
        
        eta(tinit2, numel(bndy)-1, segItr, 'remaintime', true);
        
        fprintf('\n\n');
        
    end
    
end % End of segment iterator


end



