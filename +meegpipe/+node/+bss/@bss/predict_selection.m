function y = predict_selection(obj, featVal)


model = get_training_model(obj);
hash  = get_training_hash(obj);

if isempty(model) && isempty(hash), 
    y = [];
    return;
end

y = predict(model, featVal);

if ~isempty(hash),
    yHash = false(size(y));
    for i = 1:size(featVal,1)
        featValHash = datahash.DataHash(num2str(featVal(i,:)));
        featValClass = hash(featValHash);
        if ~isempty(featValClass),
            yHash(i) = featValClass;
        end
    end
    if any(yHash),
        y = yHash;
    end
end

end