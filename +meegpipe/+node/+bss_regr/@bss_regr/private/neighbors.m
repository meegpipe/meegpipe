function [prevPcs, nextPcs] = neighbors(pcs, bndy, segItr, olap)

if numel(bndy) < 3,
    prevPcs = [];
    nextPcs = [];
    return;
end

if segItr > 1 && segItr < (numel(bndy)-1),
    winLength = bndy(segItr) - bndy(segItr-1);
    prevInit  = bndy(segItr-1)+round((1-olap/100)*winLength);
    prevPcs   = pcs(:, prevInit:bndy(segItr)-1);
    winLength = bndy(segItr+2) - bndy(segItr+1) - 1;
    nextEnd   = bndy(segItr+1)+round((olap/100)*winLength);
    nextPcs   = pcs(:, bndy(segItr+1):nextEnd);
elseif segItr == 1
    prevPcs   = [];
    winLength = bndy(segItr+2) - bndy(segItr+1) - 1;
    nextEnd   = bndy(segItr+1)+round((olap/100)*winLength);
    nextPcs   = pcs(:, bndy(segItr+1):nextEnd);
else
    winLength = bndy(segItr) - bndy(segItr-1);
    prevInit  = bndy(segItr-1)+round((1-olap/100)*winLength);
    prevPcs   = pcs(:, prevInit:bndy(segItr)-1);
    nextPcs   = [];
end

end
