function superlabels = MulSup(Im,imname,multiscale)
% Im : input image
% imname : the name of input image
% multiscale : the number of superpixels in each scale
% superlabels : the label of superpixels in each scale

supdir='.\superpixels\';
if ~isdir(supdir)
     mkdir(supdir);
end

[w,h,dim]=size(Im);
imname0=[imname(1:end-4) '.bmp'];
if dim==1
   imwrite(uint8(Im),imname0);
else
    imwrite(Im,imname0);
end

superlabels = cell(length(multiscale),1);
for scale = 1:length(multiscale)
    spnumber = multiscale(scale);
    comm=['SLICSuperpixelSegmentation' ' ' imname0 ' ' int2str(20) ' ' int2str(spnumber) ' ' supdir];
    system(comm);    
    spname=[supdir imname0(9:end-4)  '.dat'];
    superpixels=ReadDAT([w,h],spname);
    superlabels{scale} = superpixels;
end