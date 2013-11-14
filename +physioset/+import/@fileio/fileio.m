classdef fileio < physioset.import.abstract_physioset_import
    % fileio - Imports disk files using Fieldtrip's fileio module
    %
    % ## Usage synopsis:
    %
    % import physioset.import.fileio;
    % importer = fileio('FileName', 'myOutputFile');
    % data = import(mff, 'myMFFfile.fif');
    %
    % ## Accepted (optional) construction arguments (as key/values):
    %
    % * All key/values accepted by abstract_physioset_import constructor
    %
    %       Equalize: Logical scalar. Default: true
    %           If set to true, the data from different modalities
    %           (EEG, MEG, Physiology) will be scaled such that they all
    %           have similar variances. This means for instance that MEG
    %           data in T, which has much smaller scale than EEG data in V,
    %           might result in MEG data to be transformed to a smaller
    %           scale (e.g. pT instead of T). Additionally, the modality
    %           with the highest variance will be scaled so that its
    %           variance is in the range of 100 physical units. This means
    %           that EEG data originally expressed in V is very likely to
    %           be transformed to mV.
    %
    %       Trigger2Type : mjava.hash or []. Default: []
    %           A hash defining a mapping from trigger values to event
    %           types. See the notes below.
    %
    %       EegRegex : A regular expression. Default: '(EEG|EOG|E)\s?(\d+)'
    %           Regular expression that matches the labels of EEG channels.
    %
    %       EegTransRegex : A regular expression. Default: '$1 $2'
    %           Used to translate EEG channel names into new names. 
    %
    %       MegRegex : A regular expression. Default: '(MEG)(\d+)'
    %           Regular expression that matches the labels of EEG channels.
    %
    %       MegTransRegex : A regular expression. Default: '$1 $2'
    %           Used to translate MEG channel names into new names. 
    %
    %       PhysRegex : A regular expression. Default: '(ECG)(\d+)'
    %           Regular expression that matches the labels of physiology
    %           channels.
    %
    %       PhysTransRegex : A regular expression. Default: '$1 $2'
    %           Used to translate physiology channel names into new names. 
    %
    %       TriggerRegex : A regular expression. Default: 'STI101'
    %           Matches the labels of the relevant trigger channels.
    %
    %       GradUnitRegex : A regular expression. Default: '.+/m$'
    %           A regular expression that matches the measurement units for
    %           the gradiometer channels. 
    %
    % ## Notes:
    %
    % * The following Value2Type mapping:
    %
    %   val2typeMap = mjava.hash;
    %   val2typeMap{1:3} = 'Cue';
    %   val2typeMap{4:6} = 'Target';
    %
    %   will map trigger values 1, 2, 3 to an event of type Cue (and value
    %   corresponding to the trigger value) and will map trigger values 4:6 to
    %   an event of type 'Target' and value matching the corresponding trigger
    %   value.
    %
    %
    % See also: abstract_physioset_import
    
    %% Implementation .....................................................
    methods (Static, Access = 'private')
        
        grad = grad_reorder(grad, idx);
        grad = grad_change_unit(grad, newUnit);
        
    end
    
    
    %% Public interface ....................................................
    properties
        Trigger2Type    = [];
        Equalize        = true;       
        EegRegex        = '(EEG|EOG|E)\s?(\d+)';
        EegTransRegex   = '$1 $2';
        MegRegex        = '(MEG)(\d+)';
        MegTransRegex   = '$1 $2';
        PhysRegex       = '([^\s]+)\s*([^\s]*)';
        PhysTransRegex  = '$1 $2';
        TriggerRegex    = 'STI101';
        GradUnitRegex   = '.+/.?m$';
    end
    
    % Set/Get methods
    methods
        
        function obj = set.Equalize(obj, value)
            import exceptions.*;
            if isempty(value), value = true; end
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Equalize', ...
                    'Must be a logical scalar'));
            end
            obj.Equalize = value;
        end
        
        function obj = set.Trigger2Type(obj, value)
            import exceptions.*;
            if ~isempty(value) && ~isa(value, 'mjava.hash'),
                throw(InvalidPropValue('Trigger2Type', ...
                    'Must be an mjava.hash object'));
            end
            obj.Trigger2Type = value;
        end
        
    end
    
    % physioset.import.importer interface
    methods
        physObj = import(obj, filename, varargin);
    end
    
    
    % Constructor
    methods
        function obj = fileio(varargin)
            
            obj = obj@physioset.import.abstract_physioset_import(varargin{:});
            
        end
    end
    
end