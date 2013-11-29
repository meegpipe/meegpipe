function obj = learn_basis(obj, data, varargin)

import misc.eta;
import spt.centroid_spt;


obj = apply_seed(obj);

verbLevel    = get_verbose_level(obj);
verboseLabel = get_verbose_label(obj);

%% Step 1: Centroid BSS on the whole dataset
if verbLevel > 0,
    fprintf([verboseLabel ...
        'Learning %s basis for parent from %d surrogates ...'], ...
        class(obj.BSS), obj.ParentSurrogates);
end
tinit = tic;
nbSelected = nan(1, obj.ParentSurrogates);
allRankIdx = nan(size(data, 1), obj.ParentSurrogates);
bssObj     = cell(1, obj.ParentSurrogates);


surrogator = obj.Surrogator;

for surrIter = 1:obj.ParentSurrogates  
    
    surrogator = set_seed(surrogator, get_seed(obj) + surrIter*100);
    dataSurr = surrogate(surrogator, data(:,:));    
  
    bssObj{surrIter} = learn_basis(obj.BSS, dataSurr, varargin{:});
    ics = proj(bssObj{surrIter}, dataSurr);
    
    [selection, ~, rankIdx] = select(obj.SelectionCriterion, ...
        bssObj{surrIter}, ics, data); 
    
    allRankIdx(:, surrIter) = rankIdx;
    
    nbSelected(surrIter) = numel(find(selection));  
   
    if verbLevel > 0
        misc.eta(tinit, obj.ParentSurrogates, surrIter);
    end
    
end
if verbLevel > 0,
    fprintf('\n\n');
end

% Apply component selection to the bss objects
nbSelected = obj.FixNbComponents(nbSelected);
for surrIter = 1:obj.ParentSurrogates
    [~, I] = sort(allRankIdx(:,surrIter), 'descend');
    bssObj{surrIter} = select_component(bssObj{surrIter}, I(1:nbSelected));
end

bssCentroid = centroid_spt(bssObj, obj.DistanceMeasure);

%% Step 2: Apply centroid BSS to whole dataset
data = copy(data);

proj(bssCentroid, data);

%% Step 3: Split the dataset into two sets
[bssArray, winBoundary] = learn_lr_basis(obj, data, bssCentroid, ...
    [1, size(data, 2)]);

%% Step 4: Match sources accross analysis windows
for i = 1:numel(bssArray)
    bssArray{i} = match_sources(bssArray{i}, bprojmat(bssCentroid));
end

obj.BSSwin = bssArray;
obj.WinBoundary = winBoundary;

obj.ComponentSelection = 1:nb_component(bssArray{1});
obj.DimSelection       = 1:nb_dim(bssArray{1});

end



