% test
import misc.eta;

S = rand(3,100000);
S = S-repmat(mean(S,2),1,size(S,2));

S(1,:) = filter(filter.lpfilt('fc', 0.1), S(1,:));
S(2,:) = filter(filter.bpfilt('fp', [0.1 0.2]), S(2,:));
S(3,:) = filter(filter.bpfilt('fp', [0.2 0.3]), S(3,:));
A1 = rand(3);
A2 = rand(3);

X = S(:,1:100000);
X(:,1:50000) = A1*S(:,1:50000);
X(:, 50001:end) = A2*S(:, 50001:size(X,2));

clear +spt/+bss/+atdsep/cor2;

[Wa,Aa] = learn_basis(spt.bss.atdsep.atdsep('Lambda', 0.999), X);
W  = learn_basis(spt.bss.tdsep.tdsep, X(:, 1:end));

tinit = tic;
C1 = nan(3,3,1000);
C1(:,:,499) = spt.bss.atdsep.cor2(X(:,1:499)', 1);
for i = 500:2000
    C1(:,:,i) = spt.bss.atdsep.cor2(X(:,i:i+1)', 1);
    eta(tinit, 1000, i);
end

C2 = spt.bss.cor2(X(:,1:1000)', 1);