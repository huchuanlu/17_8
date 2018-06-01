% function [labels,new_evec] = ncut_B(evec,DD2_i,L,N,out_path,only_name)
function [labels,new_evec] = ncut_B(evec,DD2_i,L,N)

% data_path = [out_path 'data/']; mkdir(data_path);

%% sort eigenvectors & eigenvalues
%% k-means clustering for only pixel layer
evec = DD2_i * evec;
new_evec = evec(1:N,:);
for i=1:size(new_evec,1),
    new_evec(i,:)=new_evec(i,:)/(norm(new_evec(i,:))+1e-10);
end;
labels = k_means(new_evec',L);

% save([data_path only_name '_' int2str(L) '_ncut.mat'], 'labels','L');
