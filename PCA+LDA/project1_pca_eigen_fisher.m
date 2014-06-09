
%char path;
fid=fopen('Direct_Min_Dis.txt','w');
PCA_fid=fopen('PCA_Min_Dis.txt','w');
for train_num=5:5
    tic
    total_train_num=train_num*40;
    total_test_num=(10-train_num)*40;
    
a='imdata';
height=112;width=92;
imrgb=cell(1,400);
%imrgb=zeros(10,112,92);
pathprefex='E:\fudan研究生事务\研一上\Pattern Recognition\exercise2\ORL\orl';
namesuffix='.bmp';

%read 400 images, and convert to matrix to vector
X=zeros(10304,400);
for i=1:400
    %imrgb{i}=zeros(112*92,1);
    path=pathprefex;
    imid=num2str(i,'%03d');
    path=strcat(path,imid);
    path=strcat(path,namesuffix);
%strcat(path,)
    imrgb_tmp=imread(path);
    imrgb_tmp=double(imrgb_tmp);
    [row,col]=size(imrgb_tmp);
    imrgb{i}=imrgb_tmp(:);
    X(:,i)=imrgb{i};
    
    
    %%%%%modify here!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    %pic=imrgb(i,:,:);
    %imshow(imrgb{i});
end

%comp center of cluster
meanface=cell(1,40);%compute mean of five imgs of each people
for i=1:40
    meanface{i}=zeros(112*92,1);
    for j=9:-1:(10-train_num)
        %imrgb{10*i-j}=im2double(imrgb{10*i-j});
        imrgb{10*i-j}=double(imrgb{10*i-j});
        meanface{i}=meanface{i}+imrgb{10*i-j};
    end
    meanface{i}=meanface{i}/train_num;
    %imshow(meanface{i});
end
precision=Euc_min_dis(X,meanface,train_num);
%{
precision=0;
for i=1:40% each people
    for j=9-train_num:-1:0% each people has five imgs for testing
        %imrgb{10*i-j}=im2double(imrgb{10*i-j});
        imrgb_rowvector=imrgb{10*i-j}';
        
        %compute min_dis, use k=1 dis as min_dis;
        %meanface_rowvector=meanface{1}(:);
        meanface_rowvector=meanface{1}';
        Y=[imrgb_rowvector;meanface_rowvector];
        min_dis=pdist(Y,'euclidean');
        class=1;
        
        for k=2:40
            %meanface_rowvector=meanface{k}(:);
            meanface_rowvector=meanface{k}';
            Y=[imrgb_rowvector;meanface_rowvector];
            D=pdist(Y,'euclidean');
            if min_dis>D
                min_dis=D;
                class=k;
            end
        end
        if class==i
            precision=precision+1;
        end
        
    end
end
%}
time=toc
fprintf(fid,'train_num is %d, precision is %f,running time is %f\n',train_num,precision,toc);
%train:  train_num*40 
%test:   (10-train_num)*40

tic
%comp mean face of five faces, traing test of each people
PCA_X=zeros(10304,total_train_num);%PCA_X:200 train data
coli=1;
means_face=zeros(10304,1);
for i=1:40
    for j=9:-1:(10-train_num)
        %imrgb_colvec=imrgb{10*i-j};
        %imrgb_colvec=imrgb_colvec';
        means_face=means_face+imrgb{10*i-j};
        PCA_X(:,coli)=imrgb{10*i-j};
        coli=coli+1;
    end
end
means_face=means_face/total_train_num;
means_face_matrix=means_face;

for i=1:total_train_num-1
    means_face_matrix=[means_face_matrix,means_face];
end
PCA_X=PCA_X-means_face_matrix;
all_mean_face_matrix=means_face;
for i=1:399
    all_mean_face_matrix=[all_mean_face_matrix,means_face];
end
X=X-all_mean_face_matrix;
%[pc,score,latent,tsquare]=princomp(X','econ');
%save('xvalue','latent','-ascii');

%{
main_com_sum=0;
for i=100:200
    main_com_sum=main_com_sum+d(i,1);
end
double(main_com_sum)/sum(d)
%}


%compute X*X' eigenvalue and eigenvector(200*200),instead of X'*X(10304*10304)
d=eig(PCA_X'*PCA_X);
save('optimal_eigenvalue','d','-ascii');
[V,D]=eig(PCA_X'*PCA_X);
%{
for i=80:200
    eigen_sum=eigen_sum+d(i,1);
end
%}
%选取10304的前200个特征向量中的前121个，大于

for feature_num=39:20:199
%N-C main features
double(sum(d((total_train_num-feature_num+1):total_train_num)))/sum(d)

%original_vector_matrix=PCA_X*V;% convert eigenvector of X*X' to eigenvector of X'*X
Real_V=zeros(10304,200);

for each_feature=1:200
    Real_V(:,each_feature)=PCA_X*V(:,each_feature)/sqrt(d(each_feature,1));
end


eigenface_vector=Real_V(:,(total_train_num-feature_num+1):total_train_num);
PCA_train_test=eigenface_vector'*X;

reconstruct_face_allvector=eigenface_vector*PCA_train_test+all_mean_face_matrix;
reconstruct_face_matrix=reconstruct_face_allvector(:,19);

%{
figure(feature_num);
imshow(reshape(reconstruct_face_matrix,112,92),[0 255]);
%}

if feature_num==199
    LDA_train_test=PCA_train_test;
end

featureprefix='feature_';
featurefilename=featureprefix;
num=num2str(feature_num);
featurefilename=strcat(featurefilename,num);
save(featurefilename,'PCA_train_test','-ascii');

%comp center of cluster
PCA_meanface=cell(1,40);%compute mean of five imgs of each people
for i=1:40
    PCA_meanface{i}=zeros(feature_num,1);
    for j=9:-1:(10-train_num)
        %imrgb{10*i-j}=im2double(imrgb{10*i-j});
        %imrgb{10*i-j}=PCA_train_test(:,(10*i-j));
        PCA_meanface{i}=PCA_meanface{i}+PCA_train_test(:,(10*i-j));
    end
    PCA_meanface{i}=PCA_meanface{i}/train_num;
    %imshow(meanface{i});
end
precision=Euc_min_dis(PCA_train_test,PCA_meanface,train_num);
%{
precision=0;
for i=1:40% each people
    for j=9-train_num:-1:0% each people has five imgs for testing
        %imrgb{10*i-j}=im2double(imrgb{10*i-j});
        imrgb_rowvector=PCA_train_test(:,(10*i-j))';
        
        %compute min_dis, use k=1 dis as min_dis;
        %meanface_rowvector=meanface{1}(:);
        meanface_rowvector=PCA_meanface{1}';
        X=[imrgb_rowvector;meanface_rowvector];
        min_dis=pdist(X,'euclidean');
        class=1;
        
        for k=2:40
            %meanface_rowvector=meanface{k}(:);
            meanface_rowvector=meanface{k}';
            X=[imrgb_rowvector;meanface_rowvector];
            D=pdist(X,'euclidean');
            if min_dis>D
                min_dis=D;
                class=k;
            end
        end
        if class==i
            precision=precision+1;
        end
        
    end
end
%}

time=toc;
fprintf(PCA_fid,'PCA:main_feature_num is %d, train_num is %d, precision is %f,running time is %f\n',feature_num,train_num,precision,toc);
end

LDA_train_test;

%计算40个类中心，然后计算40个Si,计算40个mi,cell(1,40)，Sb，然后计算40个Si^(-1)Sb特征向量，wi cell(1,40)
%然后计算每个样本 分别投影到40个类别的投影向量，与该类中心投影进去的距离，计算40个距离的最小值，然后分为这类
m=cell(1,40);
for i=1:40
    m{i}=zeros(feature_num,1);
    for j=9:-1:(10-train_num)
        m{i}=m{i}+LDA_train_test(:,(10*i-j));
    end
    m{i}=m{i}/5;
end
S=cell(1,40);
Sw=zeros(feature_num,feature_num);
for i=1:40
    S{i}=zeros(feature_num,feature_num);
    for j=9:-1:(10-train_num)
        S{i}=S{i}+(LDA_train_test(:,(10*i-j))-m{i})*(LDA_train_test(:,(10*i-j))-m{i})';
    end
    S{i}=S{i}/5;
    Sw=Sw+S{i};
end
Sw=Sw/40;
total_m=zeros(feature_num,1);
for i=1:40
    total_m=total_m+m{i};
end
total_m=total_m/40;
Sb=zeros(feature_num,feature_num);
for i=1:40
    Sb=Sb+(m{i}-total_m)*(m{i}-total_m)';
end
Sb=Sb/40;
fid_LDA=fopen('fid_LDA','w');
for LDA_reduce_dim=3:3:33
w=zeros(feature_num,LDA_reduce_dim);
%for i=1:40
    [V,D]=eig(inv(Sw)*Sb);
    %w{i}=V(:,1);
%end
w=V(:,1:LDA_reduce_dim);

LDA_C_1=w'*LDA_train_test;% 39*feature_num

LDA_C_1_mean=cell(40,1);
for i=1:40
    LDA_C_1_mean{i}=zeros(LDA_reduce_dim,1);
    for j=9:-1:(10-train_num)
        LDA_C_1_mean{i}=LDA_C_1_mean{i}+LDA_C_1(:,(10*i-j));
    end
    LDA_C_1_mean{i}=LDA_C_1_mean{i}/5;
end
precision=Euc_min_dis(LDA_C_1,LDA_C_1_mean,train_num);


fprintf(fid_LDA,'LDA reduce_dim is %d,precision is %f\n',LDA_reduce_dim,precision);
end

fclose(fid_LDA);
%{
precision=0;
for i=1:40% each people
    for j=9-train_num:-1:0
        class=1;
        k=1;
        y=w{k}'*LDA_train_test(:,(10*i-j));
        my=w{k}'*m{k};
        LDA_Mindis=abs(y-my);
        for k=2:40
            y=w{k}'*LDA_train_test(:,(10*i-j));
            my=w{k}'*m{k};
            dis=abs(y-my);
            if LDA_Mindis>dis
               LDA_Mindis=dis;
               class=k;
            end
        end
        
        if class==i
            precision=precision+1;
        end
    end
end
double(precision)/((10-train_num)*40)
%}

%{
test_X=zeros(10304,200);
coli=1;
for i=1:40
    for j=9-train_num:-1:0
        imrgb_colvec=imrgb{10*i-j}(:);
        test_X(:,coli)=imrgb_colvec;
        coli=coli+1;
    end
end
PCA_test=eigenface_vector'*test_X;
%}

%{
save('optimal_eigenvector','final_D','-ascii');
d=eig(X*X');
[V,D]=eig(X*X');
save('eigenvalue','d','-ascii');
save('eigenvector','D','-ascii');
%}

%contribution=cumsum(latent)./sum(latent);
%pca_red_dim=fopen('pca_red_dim','w')
%save('pca_red_dim','score','-ascii');
%fclose(pca_red_dim);
%{
me=mean(X,2);
B=me;
for i=1:200-1
    B=[B,me];
end
A=X-B;
[U,E,V]=svd(A,0);
eigVals=diag(E);
Mp=199;
lmda=eigVals(1:Mp);
P=U(:,1:Mp);
train_wt=P'*A;
train_wt=train_wt';
save('pca_svd','train_wt','-ascii');
%}

end
fclose(fid);
fclose(PCA_fid);
