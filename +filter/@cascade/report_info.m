function [pName, pValue, pDescr]   = report_info(obj)
% REPORT_INFO - Information regarding construction parameters
%
% 
% See also: report.reportable

pName = cell(numel(obj.Filter), 1);
    
pDescr = cell(numel(obj.Filter), 1);

pValue =  cell(numel(obj.Filter), 1);

for i = 1:numel(obj.Filter),
    pValue{i} = obj.Filter{i};
    pName{i} = sprintf('Filter{%d}', i);
end