classdef cel_selector < physioset.event.selector

    properties
        CelValue = 1;
    end

    methods

        function [evArray, idx] = select(obj, evArray)

            selected = arrayfun(...
                @(x) strcmp(get(x, 'Type'), 'stm+') && ...
                (get_meta(x, 'cel') == obj.CelValue), evArray);

            evArray = evArray(selected);
            idx = find(selected);            

        end
        
        function obj = not(obj)
           
            warning('Not implemented');
            
        end

        % Constructor
        function obj = cel_selector(celValue)

            if nargin < 1, return; end

            obj.CelValue = celValue;

        end

    end    

end