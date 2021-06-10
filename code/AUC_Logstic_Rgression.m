
%% Example: Discriminant PLS using the NIPALS Algorithm
% Three classes data, each has 50 samples and 4 variables.
clear all;clc;
savepath='D:\ZZZ\External_work\fenglian\ROC_results\Revison3';
datapath='D:\ZZZ\External_work\fenglian';
cd(datapath);
tem=[];num=0;Cov1=[];
[data1 txt raw]=xlsread('BOTH.xlsx',1);
Group=data1(:,2);Cov=data1(:,1:38);

Index_Select_MOG_NMO=5:38;

data01=data1(Group==2,Index_Select_MOG_NMO);
data02=data1(Group==3,Index_Select_MOG_NMO);

filename='MS vs HC'

varname=raw(1,Index_Select_MOG_NMO+1);

data11=[data01;data02];

data11(isnan(data11)==1)=0;

y(1:size(data01,1))=1;y(1+size(data01,1):size(data01,1)+size(data02,1))=0;
y=y';
alpha=0.05;
[num m]=size(data11);

for i=1:size(data11,2)
     tem_data=data11(:,i);
     name=varname{i};
  for outer_loop=1:100  %outer loop
   Per_num=randperm(num,num);
   for j1=1:10 % 10 fold cross-validation
       Index_test=Per_num(floor(num/10)*(j1-1)+1:floor(num/10)*j1);
       Index_train=Per_num;
       Index_train(floor(num/10)*(j1-1)+1:floor(num/10)*j1)=[];

       train_data=tem_data(Index_train);
       test_data=tem_data(Index_test);
    
       train_label=y(Index_train);
       test_label=y(Index_test);
   

       [b dev stats]=glmfit(train_data,train_label,'binomial','link','logit')
       [yhat dylo dyhi]=glmval(b,test_data,'logit',stats);
       [tpr fpr thresholds]=roc(test_label,yhat);


       for j=1:length(thresholds)
           threhold(j,1)=thresholds{j}(2);
       end
       threhold=sort(threhold);
       
       for j=1:length(threhold)
           yhat1=yhat;
           yhat1(yhat>=threhold(j))=1;
           yhat1(yhat<threhold(j))=0;

           num1=length(find(test_label==1));
           num0=length(find(test_label==0));
           
           TP=sum(yhat1.*test_label);
           TN=sum((1-yhat1).*(1-test_label));
           FP=num0-TN;
           FN=num1-TP;
           TPR=TP/(TP+FN);
           FPR=FP/(FP+TN);
           
           TPRZ(j)=TPR;
           FPRZ(j)=FPR;
           Yoden(j)=TPR-FPR;
           Acc(j)=(TP+TN)/length(yhat1);
           Refx(j)=1/length(threhold)*j;Refy(j)=1/length(threhold)*j;
       end
       %[cut_Yoden zz]=max(Acc);
       [cut_Yoden zz]=max(Yoden);
       cut_value=yhat(zz);

       auc=-trapz(FPRZ,TPRZ);
       
       list(i,outer_loop,j1)=auc;
       
   end
  end
end


list1=reshape(list,size(data11,2),outer_loop*10);
list1(isnan(list1))=0;

list2(:,1)=mean(list1,2);
list2(:,2)=std(list1,0,2);
list2(:,3)=median(list1,2);
list2(:,4)=prctile(list1,25,2);
list2(:,5)=prctile(list1,75,2);
list2(:,6)=list2(:,5)-list2(:,4);

cd(savepath);
xlswrite(['ROC_results_',filename,'.xlsx'],list2);