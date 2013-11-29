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
if ~isempty(myFilt),
    % Some filters (e.g. LASIP) take a long while to compute. It is a good
    % idea to activate the filter verbose feature.
    myFilt = set_verbose(myFilt, verbose);
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
pcs   = proj(myPCA, subset(data));

if verbose,
    fprintf( [verboseLabel 'Learning %s basis ...\n\n'], class(myBSS));
end

myBSS = learn(myBSS, pcs);
ics   = proj(myBSS, pcs);

set_name(ics, [get_name(myBSS), ' activations']);
add_event(ics, get_event(data));

[~, myBSS] = cascade(myPCA, myBSS);

[selected, ~, rankVal, myCrit]  = select(myCrit, myBSS, ics, data);

if verbose,
    if  reject,
        str = 'rejected';
    else
        str = 'accepted';
    end
    fprintf([verboseLabel '%d components will be %s ...\n\n'], ...
        numel(find(selected)), str);         
end

% For convenience, we will sort everything in decreasing rank value
% This also means renaming the ICs so that IC #1 corresponds to the highest
% ranked component and so on.
% rankVal can have multiple columns (multiple features!)
[~, sortedIdx] = sort(rankVal(:,1), 'descend');

myBSS  = reorder_component(myBSS, sortedIdx);
myCrit = reorder(myCrit, sortedIdx);

myBSS = select(myBSS, selected(sortedIdx));
ics   = select(ics, sortedIdx);
ics   = set_sensors(ics, sensors.dummy(size(ics,1)));

selected = selected(sortedIdx);
% Has the user made a manual selection?
% If the user wants the manual selection of components to be
% ignored she can do either of three things:
%
% - Delete the .ini file: all windows' selections will be reset
% - Delete the "selection" parameter in the corresp. window
% - Delete the correspoding [window X] section completely.
userSel = get_runtime(obj, 'bss', 'selection', true);
if iscell(userSel), userSel = cell2mat(userSel); end
autoSel = find(selected);

if ~all(isnan(userSel)) && ~isempty(setxor(userSel, autoSel))
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

if verbose,    
    fprintf( [verboseLabel, 'Denoising ...\n\n']);   
end

% Write selection .ini file
selArg  = num2cell(icSel);
set_runtime(obj, 'bss', 'selection', selArg{:});

% Generate the HTML report
make_pca_report(obj, myPCA);
if do_reporting(obj)
   % Wee need to copy the ics or otherwise some of the reports may modify
   % them (e.g. by back-projecting them to the sensors).
   bssRep = make_bss_report(obj, myBSS, copy(ics), data);    
end
make_criterion_report(obj, myCrit, [], icSel, isAutoSel);
 
if isempty(icSel) && ~reject,
    % We select the empty set
    data(:,:) = 0;
elseif (isempty(icSel) && reject) || ...
        (numel(icSel) == size(ics, 1) && ~reject),
    % Leave data untouched    
else      
    if ~isempty(myFilt),  
        select(ics, icSel);    
        if do_reporting(obj),            
            icsIn = copy(ics);
        end
        if verbose,
            fprintf([verboseLabel 'Filtering SPCs using %s ...\n\n'], ...
                class(myFilt));
        end 
        filtfilt(myFilt, ics);
        if do_reporting(obj),           
            bss.make_filtering_report(bssRep, icsIn, ics);
        end  
        restore_selection(ics);
    end 

    if reject,
        if ~isempty(myRegrFilter),
            % Wee need to keep a backup copy of the original ics.
            select(ics, icSel);
            rejectedICs = subset(ics);
            restore_selection(ics);
        end
        noise = bproj(myBSS, ics);
        data = data - noise;
    else
        signal = bproj(myBSS, ics);
        data = assign_values(data, signal);
    end
    
    % Remove residual noise using a regression filter
    if reject && ~isempty(myRegrFilter),       
        filter(myRegrFilter, data, rejectedICs);
    end
    
end

if verbose,
    globals.set('VerboseLabel', origVerboseLabel);
end


end



