function [data, dataNew] = process(obj, data, varargin)

dataNew = [];

newData   = filtfilt(get_config(obj, 'BpFilt'), data);

% This is necessary because filtfilt returns a COPY of the input physioset
% and nodes are expected to work with data references
data(:,:) = newData(:,:);

end