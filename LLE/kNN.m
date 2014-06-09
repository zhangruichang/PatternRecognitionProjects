function [k_label] = kNN( X,i,k )
%compute Xi's k neares neighbour
% X is a cell

%   knieghbour is the k points' sequence number,for instance, compute x2's
%   5 NN, is [1,3,5,7,12],x1,x3,x5,x7,x12

dist_label=zeros(400,2);
k_label=zeros(k,1);
    for j=1:400

            X_tworow=[X{i}';X{j}'];
            dist_label(j,1)=pdist(X_tworow,'euclidean');
            dist_label(j,2)=j;
    end
    sortrows(dist_label);
    for i=2:(k+1)% min_dis is distance between i and i ,is 0;
        k_label(i-1,1)=dist_label(i,2);
    end
end
    

