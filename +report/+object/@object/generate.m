function generate(obj)


import report.object.object;
import misc.process_arguments;
import report.table.table;
import report.gallery.gallery;
import misc.dimtype_str;

generate@report.generic.generic(obj);

fid   = get_fid(obj);

%% Report generation
for i = 1:numel(obj.Objects)
    
    thisObj = obj.Objects{i};    
   
    if isa(thisObj, 'filter.abstract_dfilt'),
        
        fprintf(fid, thisObj, gallery('Level', get_level(obj)+1));
        
     elseif isa(thisObj, 'physioset.physioset')
         
         fprintf(fid, thisObj);
         
    elseif isa(thisObj, 'goo.reportable') || ...
            isa(thisObj, 'goo.reportable_handle'),
        
        level = get_level(obj) + 1;
        
        set_level(obj, get_level(obj) + 1);
        %make_title(obj, 'Object 
        fprintf(fid, '\n\n');
        fprintf(fid, '%s %s\n\n', repmat('#', 1, level), ...
            'Object properties');
        
        [pName, pValue, pDescr] = report_info(thisObj);
        
        if isempty(pValue),
            
            fprintf(fid, ...
                '\n\nNo information on this object\n\n');
            continue;
            
        end
        
        [pValue, refs] = pval2str(obj, pValue, 'propname', pName);                
 
        myTable = add_column(table, 'Property', 'Value', 'Description');
       
        for j = 1:numel(pName),
            myTable = add_row(myTable, pName{j}, pValue{j}, pDescr{j});
        end
        
        myTable = add_ref(myTable, refs(:,1), refs(:,2));        
        
        fprintf(fid, myTable);  
        
    else
        
        % Try converting the object to a struct and report on that
        warning('off', 'MATLAB:structOnObject');
        strVal = struct(thisObj);
        strVal.Class_ = class(thisObj);
        [~, thisRef] = pval2str(obj, strVal);
        warning('on', 'MATLAB:structOnObject');
        
        if isa(thisObj, 'report.named_object') || ...
                isa(thisObj, 'report.named_object_handle'),
            name = get_name(thisObj);
        else
            name = dimtype_str(thisObj);
        end
        
        ref = regexprep(name, '[^\w]+', '-');
        print_paragraph(obj, 'See [%s][%s]', name, ref);
        print_link(obj, thisRef{2}, ref);

    end
    
    fprintf(fid, '\n\n');
    
end

%pause(.5);

end




