function [Dtau,P_e,P_a]  = Kolm_Smirn(Data, Stripesize)

% Ioannis Schizas, 02/19/2024.
%Event time instants generated using MDEA.m by Korosh Mahmoodi
%Checking the Kolmogorov-Smirnov test/statistic for a certain strip length 
% between empirical estimate of CCDF 
% (of time intervals between events generated for a certain strip length) 
% and different theoretical power law CCDF



%%% Normalizing the Data to [0 1]
                                   Data = Data - min(Data) ;
                                   Data = Data ./ max(Data) ;
                                   
                                   Lenghtdata = length(Data) ;
                                   
%%% Extracting events using stripes; Each time that the Data passes from
%%% one stripe to a different one gets recorded as an event.
Ddata = Data./(Stripesize); %%% This projects Data to the interval [0 1/Stripesize]; consequently, whole numbers would limit stripes.
%%% So, using floor and ceil commands, we can determine when the time series passes from one stripe to a different one (line 57).
Event = zeros(Lenghtdata, 1);

k = 1 ;
Event(1) = 1 ;
StartEvent = zeros() ;

%%% This loop defines the events (crossings from one stripe to another.)
for i = 2 : Lenghtdata
    if ( Ddata(i) < floor(Ddata(i-1)) ) || (Ddata(i) > ceil(Ddata(i-1))  )
                        Event(i) = 1;
                        StartEvent(k) = i ;
k = k + 1;

    else

    end
end


%Event interarrival times

Dtau=[StartEvent(1), StartEvent(2:end)-StartEvent(1:end-1)];

Dtau=Dtau/512;%In seconds

%Building the complementary CDF

tau_v=[min(Dtau):(max(Dtau)-min(Dtau))/100:max(Dtau)];
%Survival probability
PY(1)=length(find(Dtau>0 & Dtau<tau_v(1)))/length(Dtau);
P_e(1)=1-(length(find(Dtau<tau_v(1)))/length(Dtau));
for i=1:length(tau_v)-1
P_e(i+1)=1-(length(find(Dtau<tau_v(i+1)))/length(Dtau));
%Survival probability
PY(i+1)=length(find(Dtau>=tau_v(i) & Dtau<tau_v(i+1)))/length(Dtau);
end
sum(PY)

SS = length(PY) ;
Survival = zeros(SS, 1);
for KK = 1 : SS
for jj = 1 : KK %-1
Survival(KK) = Survival(KK) + PY(jj) ;
end
Survival(KK) = 1 - Survival(KK) ;
end




if(0)
figure
plot(tau_v,P_e,'b*')
hold on
plot(tau_v,Survival,'ro')
end
%hold on
mu_v=[1:0.05:3];
tau_min=min(Dtau);%
for i=1:length(mu_v)
    P_a(i,:)=(tau_v/tau_min).^(1-mu_v(i));
%i=6;
%plot(tau_v,(tau_v/min(Dtau)).^(1-mu_v(i)),'r--');


if(mu_v(i)<2)
    delta=mu_v(i)-1;
    
elseif(mu_v(i)<3)
    delta=inv(mu_v(i)-1);
    
else
    delta=0.5;
    
end
delta;
end
return;











                               
                                     
              
  