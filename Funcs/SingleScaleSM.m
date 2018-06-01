function salmap_single = SingleScaleSM(im,edw,inds,test_inst_label,S1,B)

S = S1 \ ((test_inst_label{1})'+B);
S = normalize(S);

[w,h,~]=size(im);  
spnum = size(inds,1); 
salmap = zeros(w,h);
for i=1:spnum
    salmap(inds{i})=S(i);  
end

salmap_single = zeros(edw(1),edw(2));
salmap_single(edw(3):edw(4),edw(5):edw(6)) = salmap;
