function cand_y_set = Max_Violated_y_set(X,Y,inx,pos)

%%%%%%%%%%%%%%%%%%%%%%%%%
% input
% X:   d*n
% Y: 1*n_train
% inx: index_set
% pos: # of positive bags


[d,n] = size(X);
n_train = length(Y);
%y_theta = 0;

if size(Y,1) > 1
    Y = Y';
end

cand_y_set = zeros(2*d,n);
k = 1;
% knn = 1;
for i = 1:d
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % min
    y = ones(1,n);
    y(1:inx(pos+1)-1) = 0;
    for j = 1:pos
        tmpX = X(i,inx(j):inx(j+1)-1);
        [v,ix] = min(tmpX);
        y(inx(j)+ix-1) = 1;
    end
    cand_y_set(k,:) = y;
    k = k+1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %max
    y = ones(1,n);
    y(1:inx(pos+1)-1) = 0;
    for j = 1:pos
        tmpX = X(i,inx(j):inx(j+1)-1);
        [v,ix] = max(tmpX);
        y(inx(j)+ix-1) = 1;
    end
    cand_y_set(k,:) = y;
    k = k+1;
end


% l_ind = find(Y ~= 0);
% l = size(l_ind,2);
% u_ind = find(Y == 0);
% u = n - l;
% 
% eta = sum(Y);
% 
% thes = 0.8;
% 
% 
% for i = 1:d
%     %c = alpha(l_ind)'.*X(i,l_ind);
%     t = alpha(1:n)'.* X(i,:);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % +
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     yy = -ones(n,1);
%     for j = 1:pos
%         tmpt = t(inx(j):inx(j+1)-1);
%         tmpfind = find(tmpt > 0);
%         if length(tmpfind) < (inx(j+1)-inx(j))*thes
%             
% %             [val, ind] = max(tmpt);
% %             yy(inx(j)+ind-1) = 1;
%             [val, ind] = sort(-tmpt);
%             yy(inx(j)+ind(1:(inx(j+1)-inx(j))*thes)-1) = 1;
%         else
%             yy(inx(j)+tmpfind-1) = 1;
%         end
%     end
%     y_the = t*yy;
%     if y_the > y_theta
%         y_theta = y_the;
% %         y_d = i;
%         y = yy;
%     end 
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % -
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     yy = -ones(n,1);
%     for j = 1:pos
%         tmpt = t(inx(j):inx(j+1)-1);
%         tmpfind = find(tmpt < 0);
%         if length(tmpfind) < (inx(j+1)-inx(j))*thes
%             
% %             [val, ind] = min(tmpt);
% %             yy(inx(j)+ind-1) = 1;
%             [val, ind] = sort(tmpt);
%             yy(inx(j)+ind(1:(inx(j+1)-inx(j))*thes)-1) = 1;
%             
%         else
%             yy(inx(j)+tmpfind-1) = 1;
%         end
%     end
%     y_the = -t*yy;
%     if y_the > y_theta
%         y_theta = y_the;
% %         y_d = i;
%         y = yy;
%     end 
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     
% end
% 
% y = y';