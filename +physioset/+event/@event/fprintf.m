function count = fprintf(fid, ev)

count = 0;

for i = 1:numel(ev)
    
    str = event2str(ev(i));
    count = count + fprintf(fid, str);
    count = count + fprintf(fid, '\n');
    
end



end