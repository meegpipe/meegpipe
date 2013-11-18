function [data, dataNew] = process(obj, data, varargin)


import misc.eta;
import goo.globals;
import meegpipe.node.bss.bss;

verbose          = is_verbose(obj);
verboseLabel     = get_verbose_label(obj);
origVerboseLabel = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

dataNew = [];

% Configuration options
myRegrFilter = get_config(obj, 'RegrFilter');
myPCA        = get_config(obj, 'PCA');
myBSS        = get_config(obj, 'BSS');
myCrit       = get_config(obj, 'Criterion');
reject       = get_config(obj, 'Reject');
myFilt       = get_config(obj, 'Filter');

sr = data.SamplingRate;
if isa(myFilt, 'function_handle'),
    myFilt = myFilt(sr);
end

% Random seed for BSS algorithms that require it
seed = get_runtime(obj, 'bss', 'seed');
init = get_runtime(obj, 'bss', 'init');
myBSS  = set_seed(myBSS, seed);
myBSS  = set_init(myBSS, init);
set_runtime(obj, 'bss', 'seed', get_seed(myBSS));
set_runtime(obj, 'bss', 'init', get_init(myBSS, nb_component(myPCA)));

% Perform a global PCA on the whole dataset
center(data);
myPCA = learn(myPCA, data);
pcs   = proj(pca, copy(data));
make_pca_report(obj, myPCA);

if verbose,    
    fprintf( [verboseLabel 'Learning %s basis ...\n\n'], class(myBSS));    
end

myBSS = learn(myBSS, pcs);
ics   = proj(myBSS, pcs);
myBSS = cascade(myBSS, myPCA);

[selected, rankVal]  = select(criterion, myBSS, ics, data);
[rankVal, sortedIdx] = sort(rankVal, 'descend');
myBSS = select_component(myBSS, selected);
myBSS = reorder_component(myBSS, sortedIdx);

% Has the user made a manual selection?
% If the user wants the manual selection of components to be
% ignored she can do either of three things:
%
% - Delete the .ini file: all windows' selections will be reset
% - Delete the "selection" parameter in the corresp. window
% - Delete the correspoding [window X] section completely.
userSel = get_runtime(obj, 'bss', 'selection', true);
if iscell(userSel), userSel = cell2mat(userSel); end
autoSel = component_selection(obj);

if ~isnan(userSel) && ~isempty(setxor(userSel, autoSel)) 
    userSel = intersect(userSel, 1:size(ics,1));
    if verbose,
        fprintf([ get_verbose_label(obj) ...
            'User selection overrides automatic selection ' ...
            '(%d selected)...\n\n'], numel(userSel));
    end
    icSel = userSel;
    isAutoSel = false;
else
    icSel = autoSel;
    isAutoSel = true;
end

print_title(rep, 'Blind Source Separation', get_level(rep) + 2);


if do_reporting(obj),
    bssRep = childof(report.generic.new, get_report(obj));    
    set_title(bssRep, 'BSS report');
    initialize(bssRep);
  
    print_link2report(rep, bssRep);    
    
    set_name(thisICs, [get_name(bss), ' activations']);
    
    add_event(thisICs, events);
    
    bss_regr.generate_rank_report(bssRep, criterion, rankIdx, nC(segItr));
    
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






% Save diagnostic information
set_diagnostics(obj, sI, isSel, nC, pW, pA, pca);

clear misc.eta;

% Denoise by rejecting or accepting the relevant components
tinit2 = tic;



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

% Print summary information on selected components:
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


end



