classdef mri < head.head
    % MRI
    % Head model based on an MRI scan
    %
    % 
    % obj = head.mri;
    %
    % obj = head.mri('SubjectPath', subjpath);
    %
    %
    % where
    %
    % OBJ is a head.mri object
    %
    % SUBJPATH is the full path where the subject MRI surfaces are located
    %
    % 
    % 
    % See also: head.mri
    %

    properties (SetAccess =  private)
        Sensors;
        Subject;
        SubjectPath;
        SourceSpace;
        Source;
        OuterSkin;
        OuterSkull;
        InnerSkull; 
        OuterSkinDense;
        OuterSkullDense;
        InnerSkullDense; 
        FieldTripVolume;
        LeadField;
        SourceDipolesLeadField;
        InverseSolution; 
        MeasNoise;
    end
    
    properties (GetAccess = private, SetAccess = private)
        DelaunayTess;
    end
    
        
    properties (Dependent)
        NbSensors;
        NbSourceVoxels;
        NbSources;
    end
    
        
    % Global consistency check
    methods (Access=private)
        check_sources(obj); 
    end   

    % Helper methods
    methods (Static, Access = private)
        [subj, filesOut] = get_surface_files(subjectPath, nbVertices)
        value = point_depth(surfPoints, point)
    end

    
    % head.head interface
    methods
        y   = kernel(obj, sensor, dipole)
        h   = plot(obj, sensor, dipole, varargin)
        obj = add_source(obj, varargin)
        obj = remove_source(obj, sourceName)
    end
    
    % Other public methods
    methods
        obj = sensors_to_outer_skin(obj);
        obj = make_source_grid(obj, density);    
        obj = make_source_layers(obj, varargin);  % Not implemented yet!
        obj = make_bem(obj, varargin);
        index = source_index(obj, names);
        h = plot_source(obj, index, varargin);
        h = plot_source_topography(obj, index, varargin);
        h = plot_scalp_potentials(obj, index, varargin);
        h = plot_inverse_solution_dipoles(obj, varargin);
        h = plot_inverse_solution_leadfield(obj, varargin);
        obj = make_leadfield(obj);
        obj = make_source_leadfield(obj);
        obj = make_source_dipoles_leadfield(obj);
        obj = add_source_noise(obj, varargin);
        obj = add_source_activation(obj, index, activation, varargin);
        obj = get_source_centroid(obj, index, varargin);
        obj = inverse_solution(obj, varargin);
    end

    % Dependent properties
    methods
        function value = get.NbSensors(obj)
            if isempty(obj.Sensors),
                value = 0;
            else
                value = size(obj.Sensors.Cartesian, 1);
            end
        end
        
        function value = get.NbSources(obj)
            if isempty(obj.Source),
                value = 0;
            else
                value = numel(obj.Source);
            end
        end
        
        function value = get.NbSourceVoxels(obj)
            if isempty(obj.SourceSpace),
                value = 0;
            else
                value = size(obj.SourceSpace.pnt,1);
            end
        end
        
    end    
    
    % Constructor
    methods
        function obj = mri(varargin)
            import misc.process_varargin;
            import head.mri;
            import misc.plot_mesh;
          
            keySet = {'subjectpath', 'sensors'};
            subjectpath  = [];
            sensors      = [];
            nbvertices   = [];
           
            eval(process_varargin(keySet, varargin));
            
            if isempty(subjectpath),
                return;
            end            
            
            if ~ismember(subjectpath(1), {'/', '\'}) && ...
                    isempty(regexpi(subjectpath, '^\w:', 'match')),
                subjectpath = [pwd filesep subjectpath];                
            end               
            
            % Load surface files and identify the subject name
            files = head.mri.get_subject_files(subjectpath, nbvertices);
                     
            obj.Subject = files.subject;
            obj.SubjectPath = subjectpath;
            if isempty(files.outerskin),  throw(MissingOuterSkin);  end
            if isempty(files.outerskull), throw(MissingOuterSkull); end
            if isempty(files.innerskull), throw(MissingInnerSkull); end           
            
            surfaces = {'OuterSkin', 'OuterSkull', 'InnerSkull', ...
                'OuterSkinDense', 'OuterSkullDense', 'InnerSkullDense'};            
            
            for surfIter = surfaces
               thisSurf = lower(surfIter{1});
               thisFile = files.(thisSurf);
               [pnt, tri] = io.tri.read(thisFile);
               tmp = struct('pnt', pnt, 'tri', tri, 'file', thisFile);
               obj.(surfIter{1}) = tmp; 
            end            
            
            % Load sensor information
            if isempty(sensors),
                sensors = files.sensors;
            end
            
            if ischar(sensors),
                obj.Sensors = read(eeg, sensors);
            else
                id = cell(size(sensors,1),1);
                for i = 1:size(sensors,1),
                    id{i} = sprintf('e%d', i);
                end
                obj.Sensors = eeg(...
                    'Cartesian', sensors, ...
                    'label', id);
            end                        
        end
        
    end
  
end