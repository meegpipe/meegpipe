classdef bss

    methods (Abstract)


       % Methods related with the random state of the BSS algorithm
       obj          = set_seed(obj, seed);

       seed         = get_seed(obj);

       init         = get_init(obj, data);

       obj          = set_init(obj, value);

       obj          = clear_state(obj);

    end



end