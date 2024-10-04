
clc;
%clear all ;
%close all ;

% Input data
load('S037.SH.L.sess6.4chans.mat') ;

Samplerate = 512 ; % In our data the sample rates of different channels are the same, but in general they may differ 

Channels = 4 ; % Number of channels
Slice = 30 * Samplerate ; % Size of each slice of data 
Overlap = 20 * Samplerate ; % Size of the overlap of the slices of data
Newdata = Slice - Overlap ; 

L = length(DATA) ;

m = floor((L-Overlap)/Newdata) ; % Number of scaling data points


deltaChannel = zeros(m , Channels) ;
deltaChannelMeanSTEN = zeros(m , Channels) ;

for ch = 1 : Channels
ch

data = DATA(:, ch) ;


% Slicing the data of channel ch
DaTaSlice = zeros(Slice, m) ;

for n = 1 :   m
        start =  (n -1) * Newdata ;
for yytt  = 1 : Slice  
    DaTaSlice(yytt, n) = data( yytt  + start, 1 ) ;
end

end


Stripe_out = zeros(m, 1) ;
for k = 1 : m

Stripsize=[0.001:0.001:0.1]; % Search space for stripe size

mu_v=[1:0.05:3];
min_ks_val_prev=inf;
iter=1;
min_ks_val=[];
min_ks_idx=[];
for iter=1:length(Stripsize)


[Dtau,P_e,P_a]  = Kolm_Smirn(  DaTaSlice(:, k)  , Stripsize(iter));

KS_div=(max(abs(ones(size(P_a,1),1)*P_e-P_a),[],2));
[min_ks_val(iter),min_ks_idx(iter)]=min(KS_div);

%min_ks_val(iter)
min_ks_val_prev=min_ks_val(iter);

end
[min_val,min_idx]=min(min_ks_val);

%min_ks_val
 % k,min_val,min_idx 
% Stripsize(min_idx)

Stripe_out(k)=Stripsize(min_idx);
% min_ks_idx(min_idx)


end


% look at distribution of Stripe_out
%%% Find DE and de from MDEA_x using the Stripe_out and then find the slope of the linear part 
linearStartIndex = zeros(m , 1) ;
linearEndIndex = zeros(m , 1) ;
deltas = zeros(m , 1) ;
for k = 1 : m
% str = Stripe_out(k) ;
str = median(Stripe_out) ;
[DE, de]  = MDEA_z(DaTaSlice(:, k),str, 1);

 [linearStartIndex(k), linearEndIndex(k), deltas(k)] = findLinearPortion_v2(DE, de, 0.005, DaTaSlice(:, k)./str, str, 0);

 % [linearStartIndex(k), linearEndIndex(k), deltas(k)] = findTwoLinearPortions(DE, de, 0.05);
 % [linearStartIndex(k), linearEndIndex(k), deltas] = findTwoLinearPortions(DE, de, 0.005,  DaTaSlice(:, k)./median(Stripe_out), median(Stripe_out), 0);

end

deltaChannel(:, ch) = deltas ; 

% look at dist

%%% Using the median of the start and end to evaluate deltasMeanSTEN

ST = 0.2 ;  %median(linearStartIndex) /length(de) ;
EN = 0.8 ; %median(linearEndIndex) / length(de) ; 
PLOT = 0 ;

deltasMeanSTEN = zeros(m, 1);
for k = 1 : m

str = median(Stripe_out) ;
% str = Stripe_out(k) ;

deltasMeanSTEN(k) = MDEA(DaTaSlice(:, k), str, 1, ST, EN, PLOT) ;

end

deltaChannelMeanSTEN(:, ch) = deltasMeanSTEN ; 

end


plot(deltaChannel,'DisplayName','deltaChannel')

plot(deltaChannelMeanSTEN(:,1)); hold on; plot( deltaChannelMeanSTEN(:,2)) ; hold on; plot( deltaChannelMeanSTEN(:,4)) ;
hold off;
