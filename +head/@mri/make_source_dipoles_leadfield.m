function obj = make_source_dipoles_leadfield(obj)

obj.SourceDipolesLeadField = nan(obj.NbSensors, obj.NbSourceVoxels);

for i = 1:obj.NbSourceVoxels
    momentum = [];
    for j = 1:obj.NbSources
        if any(obj.Source(j).pnt == i),
            momentum = obj.Source(j).momentum(obj.Source(j).pnt==i,:);
            break;
        end
        
    end
   if isempty(momentum),
       momentum = ones(1,3)./norm(ones(1,3));
   end
   obj.SourceDipolesLeadField(:, i) = ...
       squeeze(obj.LeadField(:, :, i))*momentum';
       
end

end