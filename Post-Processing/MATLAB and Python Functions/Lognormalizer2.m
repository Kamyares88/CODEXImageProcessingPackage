%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kamyar Esmaeili Pourfarhangi, PhD
%%% Tan Lab
%%% Children's Hospital of Philadelphia
%%% 05/13/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function performs a Log normalization on the input data. It
%%% also defines a maximum cut-off on the data. Any data that is more than
%%% the mean of the top n% of the data distribution will be regarded as
%%% false positive and will become 0
%%% Inputs:
%%% Data:           The data to be normalized
%%% CutOff:         The top percentile value defined for the cut-off
%%%                 Example: If you want the cut-off to be performed on the
%%%                 top 1% of the input data, then CutOff=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output=Lognormalizer2(Data,CutOff)
[n,nn]=size(Data);
nCutOff=100-CutOff;
for i=1:nn
    temp=Data(:,i);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% cut-off modification
    %sorted_temp=sort(temp);
    p99=prctile(temp,nCutOff); %getting 99% percentile value
    abovep99tempLogic=temp>p99; abovep99temp=abovep99tempLogic.*temp; abovep99sum=sum(abovep99temp);
    Mp99=abovep99sum/sum(abovep99tempLogic); % Mean of the top 1% data acts as a cut-off beyond which 
    aboveMp99=find(temp>Mp99); % finding the id of all values above the cut-off
    [k,kk]=size(aboveMp99);
    mn=min(temp);
    for j=1:k
        temp(aboveMp99(j))=mn;
    end
    output(:,i)=log10(temp+1);
end
