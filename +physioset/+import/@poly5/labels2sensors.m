function sens = labels2sensors(labels)


% For now, create dummy sensors
sensLabels = cell(1, numel(labels)/2);

for i = 1:numel(sensLabels)
    sensLabels{i} = [labels{(i-1)*2+1} ' - ' labels{(i-1)*2+2}];
end

sens = io.edfplus.labels2sensors(sensLabels);


end