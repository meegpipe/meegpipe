function write_training_data_to_disk(obj, featVal, icSel)

fid = get_log(obj, 'criterion_training.csv');
selected = zeros(size(featVal, 1), 1);
selected(icSel) = 1;
dlmwrite(misc.fid2fname(fid), [featVal selected], 'delimiter', ',', 'precision', 6);

end