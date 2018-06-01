function [S,B] = Diffusion(im,segnum,superlabels,superpixels,lab_vals,inds)

%% get segments by FNcut
[fncut_label,~] = FNcut(im,segnum,superlabels);

%% affinity entry W_ij in Eq.8
spnum=max(superpixels(:));
adjloop=AdjcProcloop(superpixels,spnum);
edges=[];
for i=1:spnum
    indext=[];
    ind=find(adjloop(i,:)==1);
    for j=1:length(ind)
        indj=find(adjloop(ind(j),:)==1);
        indext=[indext,indj];
    end
    indext=[indext,ind];
    indext=indext((indext>i));
    indext=unique(indext);
    if(~isempty(indext))
        ed=ones(length(indext),2);
        ed(:,2)=i*ed(:,2);
        ed(:,1)=indext;
        edges=[edges;ed];
    end
end
theta=10; % control the edge weight 
weights = makeweights(edges,lab_vals,theta); 
W = adjacency(edges,weights,spnum);

%% mid-level similarity q_ij
q=zeros(spnum,spnum);
merged_supNum = max(max(fncut_label));
merged_regions = calculateRegionProps(merged_supNum,fncut_label);
allregions(1) = {inds};          allregions(2) = {merged_regions};
allsulabel(1) = {superpixels};   allsulabel(2) = {fncut_label};
connections = findHierarchy(allregions,allsulabel);
for i=1:merged_supNum
    temp=connections{i};
   for j=1:length(temp)
       for jj=1:length(temp)
           if temp(j)~=temp(jj)
              q(temp(j),temp(jj))=1;
           end
       end
   end
end

%% global uniqueness
[w,h] = size(superpixels);
colDistM = GetDistanceMatrix(lab_vals);
meanPos = GetNormedMeanPos(inds, w, h);
posDistM = GetDistanceMatrix(meanPos);
posDistM(posDistM > 3 * 0.4) = Inf;           % cut off > 3 * sigma distances
posWeight = exp(-posDistM.^2 ./ (2 * 0.4 * 0.4));
B = colDistM .* posWeight * ones(spnum, 1);
B = (B - min(B)) / (max(B) - min(B) + eps);
E = diag(B);

%% Eq.13
A = W + q;
dii = sum(A,2);
D = diag(dii,0);
V = D - A;

lamda = 5;
S = eye(spnum) + lamda*V + E;


