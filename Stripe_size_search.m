function [Stripe_out,mu_est]=Stripe_size_search(X_m,idx,L,Ovr,fs,AR_flag,beta,order)
% Ioannis Schizas, 02/19/2024.
%X_m:The data series
%idx:Which row in X_m you want to work with
%L:Window length
%Ovr:Overlap
%Finding the strip length that gerenates the smallest Kolmogorov-Smirnov test/statistic  
% between empirical estimate of CCDF 
% (of time intervals between events generated for a certain strip length) 
% and different theoretical power law CCDF

%Output
%Stripe_out:Stripe-size for each shifted window
%mu_est:The estimated mu's per window
%Ovr=floor(60*0.7);%Overalp
%L=60*512;%size(X_m,2);%10^7;%60*512;%size(X_m,2);%60*512;%Window length

%Window start and end
W_bound(1,:)=[1,L];
k=2;
while 1
%tmp=[W_bound(k-1,2)-round(Ovr*512),W_bound(k-1,2)-round(Ovr*512)+L-1];
tmp=[W_bound(k-1,2)-round(Ovr),W_bound(k-1,2)-round(Ovr)+L-1];

if(tmp(2)<size(X_m,2))
   W_bound(k,:)=tmp;
else
    break;
end
k=k+1;
end
% k
Stripsize=[0.001:0.001:0.1];%Search space
for k=1:size(W_bound,1)
%Stripsize(1)=0.001;%Initial value where CCDF looks like a delta almost

mu_v=[1:0.05:3];
min_ks_val_prev=inf;
iter=1;
min_ks_val=[];
min_ks_idx=[];
for iter=1:length(Stripsize)


y_m=X_m(idx,W_bound(k,1)+order:W_bound(k,2));

if(AR_flag)
y=decompose_single_osc(y_m,fs,30,beta);
y_m=y(2,:);
end


[Dtau,P_e,P_a]  = Kolm_Smirn(y_m, Stripsize(iter));


KS_div=(max(abs(ones(size(P_a,1),1)*P_e-P_a),[],2));

[min_ks_val(iter),min_ks_idx(iter)]=min(KS_div);

%if(min_ks_val(iter)<min_ks_val_prev)
    %Stripsize(iter+1)=Stripsize(iter)*1.1;
%else
% Stripsize(iter+1)=Stripsize(iter)./(1.2);
 %   tau_v=[min(Dtau):(max(Dtau)-min(Dtau))/60:max(Dtau)];
    %figure

  %  plot(tau_v,P_e)
   % hold on
    %plot(tau_v,(tau_v/min(Dtau)).^(1-mu_v(min_ks_idx)),'r');
    %delta(k)=inv(mu_v(min_ks_idx)-1)
    %break;
%end


%min_ks_val(iter)
min_ks_val_prev=min_ks_val(iter);

%iter=iter+1;
%if(iter>55)
  %  break;
%end
%Stripsize
end
[min_val,min_idx]=min(min_ks_val);
%min_ks_val
k,min_val,min_idx
Stripsize(min_idx)
Stripe_out(k)=Stripsize(min_idx);
min_ks_idx(min_idx)

mu_est(k)=mu_v(min_ks_idx(min_idx))
end
% mean(Stripe_out)
return;




