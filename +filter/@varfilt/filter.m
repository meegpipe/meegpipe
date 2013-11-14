function [y, obj] = filter(obj, data, varargin)
% FILTER
%
% Filters a data matrix using a VAR filter
%
%
% [y, obj] = filter(obj, data)
% [y, obj] = filter(obj, data, 'key', value, ...)
%
%
% where
%
% OBJ is a filter.varfilt object
%
% DATA is a numeric data matrix or a data type that behaves as such, e.g. 
% a pset.pset or pset.eegset object
%
% Y is the filtered data
%
%
% Accepted key/value pairs:
%
% 'Reject'  :   (logical) A logical array that especifies whether a
%               data dimension (channel) should be ignored. This is handy
%               when processing EEG/MEG datasets with bad channels.
%               Default: false(size(x,1),1)
%
%
% See also: filter.dfilt, filter.abstract_dfilt, filter.varfilt


% Documentation: class_filter_varfilt.txt
% Description: Data filtering

import misc.process_arguments;
import misc.eta;
import misc.stdout_open;

opt.reject = false(size(data,1),1);
opt.verbose = true;

[~, opt] = process_arguments(opt, varargin);

if obj.Verbose, stdout = stdout_open(obj.StdOut); end


if isa(obj, 'physioset.physioset')
    opt.reject = opt.reject | obj.BadChan;
end

try
    tinit = tic;
    if opt.verbose && obj.Verbose,
        if isa(data, 'pset.mmappset'),
            [~, name] = fileparts(obj.DataFile);
        else
            name = '';
        end
        fprintf(stdout, '(filter) VAR-filtering %s...\n\n', name);
    end
    if ~obj.AR           
        data = data(~opt.reject,:);
        varObj = learn(obj.VAR, data, 'verbose', obj.Verbose && opt.verbose);
        y = residuals(varObj, data);       
    else
        idx = find(~opt.reject);
        y = nan(numel(idx), size(data,2));        
        for i = 1:numel(idx)               
            y(i, :) = residuals(learn(obj.VAR, data(idx(i),:), ...
                'verbose', opt.verbose && obj.Verbose), data(idx(i),:));
            if opt.verbose && obj.Verbose && stdout == 1,
                eta(tinit, numel(idx), i, 'remaintime', false);
            end
        end       
    end
    
    
catch ME
    if ischar(obj.StdOut),
        fclose(stdout);
    end
    rethrow(ME);
end

if ischar(obj.StdOut),
    fclose(stdout);
end

end