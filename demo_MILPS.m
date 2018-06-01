clear;  clc;
addpath(genpath('.'));
imgRoot='.\Image\';        % path of test image
imnames=dir([imgRoot '*' '.bmp']);

saldir = '.\OUT\';        % path of saliency map
if ~isdir(saldir)
   mkdir(saldir);
end

%% Parameter settings
% three layers of superpixels
  multiscale = [150 250 350];     
% the number of the segments in FNcut
  segnum = 25;
% parameter of EdgeBoxe
  model=load('EdgeBox/models/forest/modelBsds'); model=model.model;
  model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
  opts = edgeBoxes;
  opts.alpha = .65;     % step size of sliding window search
  opts.beta  = .75;     % nms threshold for object proposals
  opts.minScore = .01;  % min score of boxes to detect
  opts.maxBoxes = 1e4;  % max number of boxes to detect
% parameter of KI-SVM
  para.gaussian = 1;  % 1 means rbf
  para.ratio = 0.25;  % rbf kernel K(x,y) = exp(-||x-y||^2/2*ratio^2*width) 
  para.im_ratio = 4;  % lamda , Imbalance ratio for positive bag. 
  para.C = 1;         % The regularization term   

for INum = 1:length(imnames)
%% Read image
    disp(INum);
    imname=[imgRoot imnames(INum).name]; 
    image=imread(imname); 
    [w,h,dim]=size(image);  
    [Im,edw] = removeframe(image,imname);   % remove the frame of image
    scale_map = zeros(w,h,length(multiscale));
%% Generate superpixels
    superlabels = MulSup(Im,imname,multiscale);
%% Compute in each scale
for scale = 1:length(multiscale)
    superpixels = superlabels{scale};
%% Extract features   
    [inds,lab_vals,fgProb,sup_feat] = Features(Im,superpixels);
%% Generate object proposals
    bbs = edgeBoxes(Im,model,opts); 
%% Proposals selecting
   [bbssel,bbssel_inds] = ProposalSel(Im,bbs,fgProb,superpixels,inds);
%% Bag Construction
   [pos_bag,neg_bag,traindata,testdata] = BagCons(Im,bbssel,bbssel_inds,sup_feat,inds);
%% KI-SVM
   [test_bag_label, test_inst_label, test_bag_pre, test_ins_pre]= Inst_KI_SVM(para, traindata, testdata);
%% Diffusion function
   [S1,B] = Diffusion(Im,segnum,superlabels,superpixels,lab_vals,inds);
%% Compute single-scale saliency map
   scale_map(:,:,scale) = SingleScaleSM(Im,edw,inds,test_inst_label,S1,B);
end
%% Compute multi-scale saliency map
    finalmap = mat2gray(sum(scale_map,3));
    imwrite(finalmap,[saldir,imname(9:end-4),'.jpg']); 
end



