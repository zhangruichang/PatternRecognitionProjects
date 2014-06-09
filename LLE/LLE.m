pathprefex='F:\Zhangruichang\PatternRecognition\ORL\orl';
namesuffix='.bmp';

train_num=5;
X=zeros(10304,400);
imrgb=cell(1,400);
imrgb_matrix=cell(1,400);
N=400;
for i=1:400
    %imrgb{i}=zeros(112*92,1);
    path=pathprefex;
    imid=num2str(i,'%03d');
    path=strcat(path,imid);
    path=strcat(path,namesuffix);
%strcat(path,)
    imrgb_tmp=imread(path);
    imrgb_matrix{i}=imrgb_tmp;
    imrgb_tmp=double(imrgb_tmp);
    [row,col]=size(imrgb_tmp);
    imrgb{i}=imrgb_tmp(:);
    X(:,i)=imrgb{i};
end
fid=fopen('k_reduce_dim_precision','w');
for reduce_dim=2:1:2
    for k=41:1:41  %select k nearest neighbours of a point
k_lable=zeros(k,1);
Q=zeros(k,k);
W=zeros(N,N);
I=eye(k,k);
r=0.1;
for i=1:400
    k_lable=kNN(imrgb,i,k);
    %k_lable=uint16(k_lable);
    for p=1:k
        for q=1:k
            Q(p,q)=(imrgb{i}-imrgb{k_lable(p,1)})'*(imrgb{i}-imrgb{k_lable(q,1)});
        end
    end
    if det(Q)==0
        Q=Q+r*I;
    end
        Q_rev=inv(Q);
        for j=1:k
            W(i,j)=sum(Q_rev(j,:))/sum(sum(Q_rev));
        end
end
I_N=eye(N,N);
M=(W-I_N)'*(W-I_N);
[V,D]=eig(M);
Y=V(:,2:(reduce_dim+1));
rev_Y=Y';
LLE_mean=cell(1,40);
for i=1:40
    LLE_mean{i}=zeros(reduce_dim,1);
    for j=9:-1:(10-train_num)
        LLE_mean{i}=LLE_mean{i}+rev_Y(:,(10*i-j));
    end
    LLE_mean{i}=LLE_mean{i}/train_num;
end
precision=Euc_min_dis(rev_Y,LLE_mean,train_num);
%precision
fprintf(fid,'K is: %d,reduce_dimansion is %d,precision is %f\n',k,reduce_dim,precision);
    end
end
fclose(fid);
figure(1);
vertical=Y(1:10,1);
horizontal=Y(1:10,2);
plot(Y(1:10,1),Y(1:10,2),'bs');
figure(2);
%{
plot(Y(21:30,1),Y(21:30,2),'rs');
plot(Y(31:40,1),Y(31:40,2),'cs');
plot(Y(41:50,1),Y(41:50,2),'ms');
plot(Y(51:60,1),Y(51:60,2),'ys');
plot(Y(61:70,1),Y(61:70,2),'ks');
%}
imshow(imrgb_matrix{1});




