classdef erp < meegpipe.node.abstract_node
    % erp - Compute average ERPs
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.erp')">misc.md_help(''meegpipe.node.erp'')</a>

    properties (SetAccess = private, GetAccess = private)
        
        ERPWaveform;
        ERPSensors;
        ERPFeatures;
        ERPSensorsImgIdx;
        
    end
    
    
    %% PUBLIC INTERFACE ...................................................
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = 'Nodes of class __erp__ compute average ERPs ';
            
        end
        
    end
    
    % Other public methods (declared and defined here)
    methods
        
        function wv = get_erp_waveform(obj)
            
            wv = obj.ERPWaveform;
            
        end
        
        function [sens, idx] = get_erp_sensors(obj)
            
            sens = obj.ERPSensors;
            idx  = obj.ERPSensorsImgIdx;
            
        end
        
        function feat = get_erp_features(obj)
            
            feat = obj.ERPFeatures;
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = erp(varargin)
            
            import pset.selector.cascade;
            import pset.selector.good_samples;
            import pset.selector.sensor_class;
            
            % IMPORTANT:
            % Class abstract_node implements copy construction for all its
            % sub-classes!
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'erp');
            end
            
            if isempty(get_data_selector(obj));
                % Usually a channel interpolation node will precede any ERP
                % node and thus we don't select only the good channels. 
                % However, we must discard the bad data samples or
                % otherwise any bad_epochs node before this node will have
                % no effect.
                dataSel = sensor_class('Type', {'EEG', 'MEG'});
                set_data_selector(obj, cascade(good_samples, dataSel));
            end            
            
        end
        
    end
    
    
end