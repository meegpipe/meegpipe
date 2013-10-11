function selected = simple_guess(rankIndex)

selected = true(size(rankIndex));

[rISorted, I] = sort(rankIndex, 'descend');
rankDiff = diff(rISorted);

if ~any(rankDiff) > 1e-6,
    selected(1:end) = false;
    return;
end

[~, idx] = max(abs(rankDiff));
selected(I(idx+1:end)) = false;

end