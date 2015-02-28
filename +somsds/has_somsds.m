function bool = has_somsds()
% HAS_SOMSDS - Returns True if the somsds scripts are installed

status = 0;
evalc('status = system(''somsds_link2rec'')');
bool = isunix && status == 255;

end