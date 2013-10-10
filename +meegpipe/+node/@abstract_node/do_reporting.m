function bool = do_reporting(obj)

import meegpipe.node.globals;

parentNode = get_parent(obj);

bool = obj.GenerateReport && globals.get.GenerateReport;

if ~isempty(parentNode),
    bool = bool & do_reporting(parentNode);
end

end