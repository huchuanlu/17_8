function [test_bag_label, test_inst_label, test_bag_pre, test_ins_pre] = Inst_KI_SVM(opt, train_data, test_data)
%Inst_KI_SVM is a convex method for locating Region Of Interest(ROI) with multi-instance learning 
%
%N.B.: Inst_KI_SVM employs a new Matlab software (libsvm-mat-2.88-MI-SVM)
%
%    Syntax
%
%       function [test_bag_label, test_inst_label, test_bag_pre, test_ins_pre] = Inst_KI_SVM(opt, train_data, test_data)
%
%    Description
%
%       Inst_KI_SVM takes,
%           opt          - A struct, includes the parameters. 
%                        1)opt.gaussian. If opt.gaussian = 1 means rbf
%                        kernel is used; If opt.gaussian = 0 means linear
%                        kernel is used; [Default opt.gaussian = 0]
%                        2)opt.ratio. If rbf kernel K(x,y) =
%                        exp(-||x-y||^2/2*ratio^2*width) is used, the
%                        opt.ratio = ratio. Here width is average distance
%                        between all instances.  [Default opt.ratio = 1]
%                        3)opt.im_ratio. Imbalance ratio for positive
%                        bags.[Default opt.im_ratio = 1]
%                        4)opt.C. The regularization term in SVM [Default
%                        opt.C = 1]
%                        5)opt.iteration. The maximal iteration for label
%                        generation.[Default opt.iteration = 20]
%                        6)opt.minstep. The minimal iteration for label
%                        genernation. [Default opt.minstep = 5]
%           train_data   - An Nx2 cell,the jth instance of the ith training
%                          bag is stored in train_data{i,1}(j,:), the ith label of the ith
%                           training bag is stored in  train_data{i,2}
%           test_data    - A M*2 cell, the jth instance of the ith training
%                          bag is stored in test_data{i,1}(j,:). the ith label of the ith
%                           testing bag is set as  test_data{i,2} = 0; The label of testing bags will not be used.  

%      and returns,
%           test_bag_label    - An M*1 array, the predicted label of the ith testing bags is stored
%                               in test_bag_label(i)
%           test_inst_label   - An Mx1 cell,  the predicted label of the
%                               jth instance of the ith training bag is stored in the test_inst_label{i,1}(j) 
%           test_bag_pre      - An M*1 array, the prediction of the ith testing bags is stored
%                               in test_bag_label(i)
%           test_ins_pre      - An Mx1 cell,  the prediction label of the
%                               jth instance of the ith training bag is
%                               stored in the test_inst_label{i,1}(j)                             
%
% [1] Y.-F. Li, J. T. Kwok, I. W. Tsang, and Z.-H. Zhou. A convex method for locating regions of interest with multi-instance learning. In: Proceedings of the 20th European Conference on Machine Learning (ECML'09), Bled, Slovenia, 2009. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add path
% addpath('libsvm-mat-2.88-MI-svm');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(opt,'gaussian');
    opt.gaussian = 0;
end
if ~isfield(opt,'ratio');
    opt.ratio = 1;
end
if ~isfield(opt,'im_ratio');
    opt.im_ratio = 1;
end
if ~isfield(opt,'iteration');
    opt.iteration = 20;
end
if ~isfield(opt,'minstep');
    opt.minstep = 5;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[X,Y,inx,pos] = celltomatrix(train_data);
X = X';
[X_test,Y_test,inx_test,pos_test,inx_test2] = celltomatrix(test_data);
X_test = X_test';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[d,n] = size(X);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if opt.gaussian == 1
    
    ratio = opt.ratio;
    K_train = normalization_gaussian(ratio,X);
    K_test = normalization_gaussian(ratio, X, X_test);
    eigopt.disp = 0;
%     [U,S] = eigs(K_train,20,'lm',eigopt);
    [U,S] = eigs(K_train,min(20,(size(K_train,1)-2)),'lm',eigopt);
    tmps = sqrt(diag(S));
    newX = diag(tmps)*U';
    clear U S;

else
    K_train = X'*X+1;
    K_test = X'*X_test+1;
    newX = [X;ones(1,n)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_train = n - inx(pos+1) +1 + pos; 
y_train = -ones(1,n_train);
y_train(1:pos) = 1;


if opt.gaussian == 1
    cand_y_set = Max_Violated_y_set(newX,y_train,inx,pos);
else
    cand_y_set = Max_Violated_y_set(newX,y_train,inx,pos);
end

ini_y = ones(1,n);
for i = 1:pos
    ini_y(inx(i):inx(i+1)-1) = (1/(inx(i+1)-inx(i))); 
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ini_y(1)= 0;
nk = 1;
bestobj = inf;
y_set = ini_y;
obj_set = [];

iter = 0;
sigma = 1;
alpha = 1/n_train*ones(n_train,1);
im_rat = opt.im_ratio;

flag = 1;

while flag && iter <= opt.iteration
%      disp([num2str(iter) '....................']);
       
     if opt.gaussian == 1

        opt_svm = ['-s 5 -c ' num2str(opt.C) ' -t 4 -m 500'];
        K1 = [(1:n)', K_train];
        model = svmtrain(y_train',K1,opt_svm,iter+1,y_set',sigma,alpha,inx,im_rat);
     else
         
        opt_svm = ['-s 5 -c ' num2str(opt.C) ' -t 4'];
        K1 = [(1:n)', K_train];
        model = svmtrain(y_train',K1,opt_svm,iter+1,y_set',sigma,alpha,inx,im_rat);
     end     
         
     obj = model.obj;
     
     if obj > bestobj
         sigma = model.sigma;
         model = svmtrain(y_train',K1,opt_svm,iter+1,y_set',sigma,alpha,inx,im_rat);
     end
     
     if  abs(obj-bestobj) < 0.01*abs(obj) || obj > bestobj 
         if iter >= opt.minstep
            flag = 0;
         end
     end
     bestobj = obj;
     
     if flag
         
         bestobj = obj;
         nk = nk + 1;
         alpha = model.alpha(1:n_train);               
         yy_set = [cand_y_set; y_set(2:end,:)];
           if opt.gaussian == 1
                y = Find_y_linear(alpha,y_train,newX,yy_set,inx,pos);
           else
                y = Find_y_linear(alpha,y_train,newX,yy_set,inx,pos);
           end
       
        
         y_set = [y_set;y];
         obj_set = [obj_set,bestobj];
         
         sigma = [model.sigma',0];
         iter = iter + 1;
        
     end
        
end


alpha = model.alpha(1:n_train);
[test_bag_label, test_inst_label, test_bag_pre, test_ins_pre] = Inst_KISVM_prediction(alpha, y_train, y_set, sigma, inx, K_test, inx_test2);


