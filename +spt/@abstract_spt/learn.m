function obj = learn(obj, data)
% LEARN - Learn spatial tranformation basis functions

import goo.globals;
import misc.dimtype_str;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

origVerbose = globals.get.Verbose;
globals.set('Verbose', false);
origVerboseLabel = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

if verbose,
    fprintf([verboseLabel ...
        'Learning from %s data\n\n'], dimtype_str(data));
    fprintf(...
        [verboseLabel 'Learning %d spatial basis functions with %s...'], ...
        size(data,1), class(obj));
end

obj = learn_basis(obj, data);

if verbose,
     fprintf('[learned %d basis]\n\n', nb_component(obj));
end

globals.set('VerboseLabel', origVerboseLabel);
globals.set('Verbose', origVerbose);

end



