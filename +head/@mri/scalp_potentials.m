function data = scalp_potentials(obj, varargin)

import misc.process_varargin;

keySet = {'time'};
time = [];
eval(process_varargin(keySet, varargin));

if isempty(time),
    time = 1;
   for i = 1:obj.NbSources
       time = max(time, numel(obj.Source(i).pnt));
   end
end

data = nan(obj.NbSensors, numel(time));
for i = 1:numel(time)
   data(:, i) = sum(source_leadfield(obj, 1:obj.NbSources, 'Time', time, ...
       varargin{:}),2); 
   
   if ~isempty(obj.MeasNoise),
      data(:,i) = data(:,i) + obj.MeasNoise(:,i); 
   end
   
end



end