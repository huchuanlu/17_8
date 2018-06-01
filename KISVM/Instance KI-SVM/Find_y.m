function [y,best_value] = Find_y(alpha,y_train,K_train,cand_y_set,inx,pos)


for i = 1:size(cand_y_set,1)
    tmpy = cand_y_set(i,:);
    value = cal_value(alpha,y_train,K_train,inx,tmpy,1,pos);
    
    if i == 1
        best_value = value;
        y = cand_y_set(i,:);
    elseif value > best_value
        best_value = value;
        y = cand_y_set(i,:);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% greedy search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
times = 1;
for t = 1:times
    for i = 1:pos
        ix = find(y(inx(i):inx(i+1)-1));
        y(inx(i)+ix-1)  = 0;
        tmax = cal_matrix(alpha,y_train,K_train,inx,i,tmpy);
        [v,ix] = max(tmax);
        y(inx(i)+ix-1)  = 1;
    end
end


    function value = cal_value(alpha,y_train,K,inx,tmpy,sp,ep)
        ay = alpha'.* y_train;
        n = length(ay);
        KK = zeros(ep-sp+1,n);
        for i1 = sp: ep
            for i2 = 1:n
                
                if i2 < i1
                    KK(i1-sp+1,i2)  = KK(i2-sp+1,i1);
                else
                    KK(i1-sp+1,i2) = tmpy(inx(i1):inx(i1+1)-1)*K(inx(i1):inx(i1+1)-1,inx(i2):inx(i2+1)-1)*tmpy(inx(i2):inx(i2+1)-1)';
                end
            end
        end
        value = ay(sp:ep)*KK*ay'-0.5*ay(sp:ep)*KK(:,sp:ep)*ay(sp:ep)';
        
    end
    

    function tmax = cal_matrix(alpha,y_train,K_train,inx,i,tmpy)
        ay = alpha'.* y_train;
        n = length(ay);
        mt = inx(i+1)-inx(i);
        tmax = zeros(mt,n);
        for i1 = 1:mt
            for i2 = 1:n
                if i2 == i
                   tmax(i1,i2) = 0;
                else
                    tmax(i1,i2) = K_train(inx(i)+i1-1,inx(i2):inx(i2+1)-1)*tmpy(inx(i2):inx(i2+1)-1)'; 
                end
            end
        end
        tmax = tmax*ay'*ay(i);
    end

end
