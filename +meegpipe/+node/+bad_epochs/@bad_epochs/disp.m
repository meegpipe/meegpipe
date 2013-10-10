function disp(obj)

import goo.disp_class_info;


disp_class_info(obj);

disp_body(obj);

disp_body(get_config(obj));

crit = get_config(get_config(obj, 'Criterion'));
if ~isempty(crit),
    fprintf('\nNode criterion properties:\n\n');
    disp_body(crit);
end


fprintf('\n');

end

