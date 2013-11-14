classdef dummy < spt.criterion.abstract_criterion
    % dummy - A dummy selection criterion for illustration purposes
    %
    % See: <a href="matlab:misc.md_help('spt.criterion.dummy')">misc.md_help(''spt.criterion.dummy'')</a>
   
    
    
    
    %% spt.criterion.criterion interface
    methods
        
        % The select() method ranks the input components and returns a set
        % of indices of selected components. The select() method can be
        % called with a variable number of arguments, but you can be sure
        % of receiving at least two arguments:
        %
        % sptObj: The spatial transformation object, e.g. a 
        % spt.bss.fastica.fastica object. 
        %
        % sptAct: A KxM matrix with M samples from K spatial components. 
        %
        % Method select should provide at least two output arguments:
        %
        % idx: An array with the indices of the selected components
        %
        % rankIdx: An array with the rank value associated to each
        % component. If you criterion does not rank components in any way
        % (e.g. the dummy criterion does not rank them) then you should set
        % rankIdx to an array of constant values (e.g. an array of ones).
        function [idx, rankIdx] = select(obj, sptObj, sptAct, varargin)
            
            % sptObj contains all the information regarding the spatial 
            % characteristics of the transformation (e.g. the projection and
            % backprojection matrix). It is ignored in this criterion, but
            % other criterions do use it.
            
            if negated(obj),
                
                idx = false(1, size(sptAct,1));
                
                rankIdx = zeros(1, size(sptAct,1));
                
            else
                idx = true(1, size(sptAct,1));
                
                rankIdx = ones(1, size(sptAct,1));
            end
            
        end
        
    end
    
    
    %% Constructor
    methods
        
        function obj = dummy(varargin)
            
            obj = obj@spt.criterion.abstract_criterion(varargin{:});
            
        end       
        
        
    end
    
    
    
end