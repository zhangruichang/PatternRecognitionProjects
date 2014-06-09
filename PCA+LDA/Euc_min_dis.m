function precision = Euc_min_dis(imrgb,meanface,train_num )
%MIN_DIS Summary of this function goes here
%   imrgb is dim* N
%meanface is C cells, each is dim* 1
%k=10;
fid=fopen('An efficient alg in fish','w');
precision=0;
dist=zeros(40,2);
%count=zeros(40,1);
for i=1:40% each people
    for j=9-train_num:-1:0% each people has five imgs for testing
        %imrgb{10*i-j}=im2double(imrgb{10*i-j});
        imrgb_rowvector=imrgb(:,(10*i-j))';
        
        %compute min_dis, use k=1 dis as min_dis;
        %meanface_rowvector=meanface{1}(:);
        meanface_rowvector=meanface{1}';
        Y=[imrgb_rowvector;meanface_rowvector];
        min_dis=pdist(Y,'euclidean');
        dist(1,1)=min_dis;dist(1,2)=1;
        class=1;
        
        for k=2:40
            %meanface_rowvector=meanface{k}(:);
            meanface_rowvector=meanface{k}';
            Y=[imrgb_rowvector;meanface_rowvector];
            D=pdist(Y,'euclidean');
            dist(k,1)=D;dist(k,2)=k;
            if min_dis>D
                min_dis=D;
                class=k;
            end
        end
        
         fprintf(fid,'right class id: %d,sample id: %d ,testing class id: %d',i,(10*i-j),class);
        if class==i
            precision=precision+1;
            fprintf(fid,'\n');
        else
            fprintf(fid,' ERROR!!\n');
        end
        %{
        sortrows(dist);
        for kk=1:k
            count(dist(kk,2),1)=count(dist(kk,2),1)+1;
        end
        %}
    end
end
precision=double(precision)/((10-train_num)*40);
fprintf(fid,'precision: %f',precision);
fclose(fid);
end

