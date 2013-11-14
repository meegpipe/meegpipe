function myProtEvs = generate_block_events(prot, protHdr, time, status)

import physioset.import.pupillator;

isRed    = cellfun(@(x) strcmp(x, 'red [0-255]'), protHdr);
isBlue   = cellfun(@(x) strcmp(x, 'blue [0-255]'), protHdr);
isPVT    = cellfun(@(x) strcmp(x, 'pvt'), protHdr);
[~, transitionSampl] = unique(status, 'first');

prot2 = prot(1:3:end,:);

seq = repmat('D', size(prot2,1), 1);
seq(prot2(:,isRed)>0)  = 'R';
seq(prot2(:,isBlue)>0) = 'B';

transitionSampl = [transitionSampl(:); numel(time)];

transitionTime = time(transitionSampl);

isPVTBlock = prot(:,isPVT) > 0; %2:3:21;

myProtEvs = pupillator.block_events(transitionSampl, transitionTime, seq, isPVTBlock);