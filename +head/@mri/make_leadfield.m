function obj = make_leadfield(obj)
import fieldtrip.ft_prepare_leadfield;

MissingBEM = MException('head:mri:make_source_grid_leadfield', ...
    'You need to run make_bem() first!');

if isempty(obj.FieldTripVolume),
    throw(MissingBEM);
end


% Generate the leadfield matrix
cfg.grid.pos = obj.SourceSpace.pnt;
cfg.grid.inside = 1:size(obj.SourceSpace.pnt, 1);
cfg.grid.outside = [];
cfg.vol = obj.FieldTripVolume;
cfg.elec = fieldtrip(obj.Sensors);
try
    grid = ft_prepare_leadfield(cfg);
catch  %#ok<CTCH>
    % Older versions of fieldtrip have a bug that requires leadfield to be
    % called twice
    grid = ft_prepare_leadfield(cfg);
end

obj.LeadField = nan(obj.NbSensors, 3, obj.NbSourceVoxels);
for i = 1:obj.NbSourceVoxels,
    obj.LeadField(:,:,i) = grid.leadfield{i};
end


end