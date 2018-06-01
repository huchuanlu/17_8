function [fncut_label,imgMarkup] = FNcut(image,segnum,superlabels)
 % segnum :the number of the segments
 % fncut_label : the label of segments
 % imgMarkup : The same image as the inputs with the red channel set to 1 along the borders of segments

% load('D:\MIL-proposal-fgprob1 - ����\sup-PASCAL\12_150.mat')
% superlabels{1} = superpixels;
% load('D:\MIL-proposal-fgprob1 - ����\sup-PASCAL\12_250.mat')
% superlabels{2} = superpixels;
% load('D:\MIL-proposal-fgprob1 - ����\sup-PASCAL\12_350.mat')
% superlabels{3} = superpixels;
% image = imread('E:\database\Pascal-S\F-PASCAL_S-Image\12.jpg');
% segnum = 30;

scale = 1;        % image scale
lambda = 0.99999;   % a weighting values for smoothness terms
para.K = 3;         % the number of the over-segmention layers
para.alpha = 0.001; % the relationship between pixels and regions
para.beta  =  60;   % the variance of the color differences
para.gamma = 1.0;   % the smoothness between regions in the same layer

ww = size(image,1); hh = size(image,2);
image = imresize(image,scale); image = im2double(image); X = size(image,1); Y = size(image,2);
W = make_weight_matrix(image,superlabels,para); 
  % make eigenspace
[B,evec,evals,DD2_i] = make_spectral_analysis(W,segnum,lambda);
   % spectral segmentation
labels = ncut_B(evec(:,1:segnum),DD2_i,segnum,X*Y);
fncut_label = reshape(labels,[ww hh]);
[imgMasks,segOutline,imgMarkup]=segoutput(image,fncut_label); % make the resulted image with red boundaries
% figure;imshow(imgMarkup);

% im_show = mat2gray(im_label);
% figure;imshow(im_show);
% imwrite(imgMarkup,OutImgName_1); 
%    clear W label_img seg seg_img;
%    clear img B evec evals DD2_i labels;
