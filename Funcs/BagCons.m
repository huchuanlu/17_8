function [pos_bag,neg_bag,traindata,testdata] = BagCons(im,bbssel,bbssel_inds,sup_feat,inds)

%% Postive bags
posbox_inds =  bbssel_inds(1:min(70,size(bbssel_inds,1)),:);
pos_bag = cell(length(posbox_inds),2);
for i=1:length(posbox_inds)
    pos_bag{i,1}=sup_feat(posbox_inds{i},:);
    pos_bag{i,2}=1;
end

%% Negative bag
% objectness score for each superpixel
[w,h,~]=size(im); 
ObjectMap=zeros(w,h);
bbssel(:,5) = (bbssel(:,5)-min(bbssel(:,5)))/(max(bbssel(:,5))-min(bbssel(:,5)));
for idx = 1:size(bbssel,1)
    xmin = uint16(bbssel(idx,1));
    ymin = uint16(bbssel(idx,2));
    xmax = uint16(bbssel(idx,3));
    ymax = uint16(bbssel(idx,4));
    score = bbssel(idx,5);
    temp=zeros(w,h);
    temp(ymin:ymax,xmin:xmax)=score;
    ObjectMap=ObjectMap+temp;
end
ObjectMap = mat2gray(ObjectMap);

% foreground mask map
thresh = 0.8*mean(ObjectMap(:));
ObjectMap(ObjectMap>=thresh)=1;

% find negative instance
spnum = size(sup_feat,1);
sup_saliency = zeros(spnum,1);  
for i=1:spnum
    sup_saliency(i) = mean(ObjectMap(inds{i}));
end

neg_thresh = 0.4; 
negsup_inds = find(sup_saliency<= neg_thresh);

% In the case that the number of negative instance is small
while length(negsup_inds)<8
    neg_thresh = neg_thresh+0.1; 
    neg_supind0 = find(sup_saliency<= neg_thresh);
    negsup_inds = [negsup_inds;neg_supind0];
    negsup_inds = unique(negsup_inds);
end

% negative bag
neg_bag = cell(1,2);
neg_bag{1}=sup_feat(negsup_inds,:);
neg_bag{2}=-1;

%% training data for KI-SVM
traindata = [pos_bag;neg_bag];

%% test data for KI-SVM
testdata=cell(1,2);
testdata{1}=sup_feat;


