function [data, dataNew] = process(obj, data, varargin)
% PROCESS - Rejects bad samples
%
% data = process(obj, data)
%
% Where
%
% DATA is a physioset object
%
%
% See also: physioset, bad_samples

dataNew = [];

find(obj, data, ...
    get_config(obj, 'MADs'), ...
    get_config(obj, 'WindowLength'), ...
    get_config(obj, 'WindowShift'), ...
    get_config(obj, 'Percentile'), ...
    get_config(obj, 'MinDuration'));  %#ok<GTARG>


end