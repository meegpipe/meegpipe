classdef abstract_bss < spt.generic.generic & spt.bss.bss
    
    properties (SetAccess = private, GetAccess = private)
        
        RandState_;
        Init_;
        
    end
    
    
    methods
        
        % Re-definition of goo.reportable interface
        function [pName, pVal, pDescr] = report_info(obj)
            
            [pName, pVal, pDescr] = report_info@spt.generic.generic(obj);
            cfg = get_config(obj);
            [pName2, pVal2, pDescr2] = report_info(cfg);
            pName  = [pName(:);pName2(:)];
            pVal   = [pVal(:);pVal2(:)];
            pDescr = [pDescr(:); pDescr2(:)];
            
        end
        
        % spt.spt interface
        function obj = clear_state(obj)
            
            obj.Init_      = [];
            obj.RandState_ = [];
            
        end
        
        function seed = get_seed(obj)
            
            import misc.isnatural; 
            
            if isempty(obj.RandState_) || ~isnatural(obj.RandState_),
                seed = randi(1e9);                
            else
                seed = obj.RandState_;
            end
            
        end
        
        function obj = set_seed(obj, value)
            
                obj.RandState_ = value;
            
        end
        
        function init = get_init(obj, ~)
            
           init = obj.Init_;
            
        end
        
        function obj = set_init(obj, value)
            
            obj.Init_ = value;
            
        end
        
    end
    
    
    
    % Constructor
    methods
        
        function obj = abstract_bss(varargin)
            
            obj = obj@spt.generic.generic(varargin{:});
            
        end
        
    end
    
    
    
end