function [pName, pValue, pDescr]   = report_info(obj)
% REPORT_INFO - Information regarding construction parameters
%
% 
% See also: report.reportable

% Documentation: class_filter_sbfilt.txt
% Description: Information regarding construction arguments

pName = {...
    'FStop', ...   
    'PersistentMemory' ...
    };
    
pDescr = {...
    'Stopband boundaries', ...   
    'Is the filter memory persistent?' ...
    };

pValue = cellfun(@(x) obj.(x), pName, 'UniformOutput', false);
