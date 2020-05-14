%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kamyar Esmaeili Pourfarhangi, PhD
%%% Tan Lab
%%% Children's Hospital of Philadelphia
%%% 05/13/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function visualizes the clusters marker expression. It uses
%%%     Hierarchical Clustering to place close clusters near each other. The
%%%     function also saves a tabular plot depicting the number of cells within
%%%     each cluster. The order of clusters in the table follows the same order
%%%     as the clusters have in the marker expression figure.
%%% The function also saves both figures in the output folder
%%% 
%%% Inputs:
%%% ChannelNames:         A cell array containing the name of each
%%%                       channel/marker. The order here should match the
%%%                       order channels are arranged in the Normalized 
%%%                       Data matrix.
%%% NormSignal:           Normalized Data matrix
%%% ClusterDataCSV:       Name of the csv file conatining the clustering
%%%                       results
%%%                       Example: 'CellClusters_Kmeans.csv'
%%% ClusterNum:           The number of clusters selected as the best
%%%                       representing the cell types within the data
%%%                       detected by the QC step.
%%% HCfigureName:         A string used as a name for saving the cluster
%%%                       marker expression plot
%%% CellNumberTableName:  A string used as a name for saving the cluster
%%%                       cell number table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [DataCateg]=HConClusters(ChannelNames,NormSignal,ClusterDataCSV,ClusterNum,HCfigureName,CellNumberTableName)
clData=csvread(ClusterDataCSV);
clData=clData(:,ClusterNum);

DataCateg = cell2cluster(NormSignal,clData);
DataCateg_Avg = AvgCluster(DataCateg);
% HC figure
clusterog = clustergram((DataCateg_Avg),'ColumnLabels',ChannelNames,'Colormap',redbluecmap,...
'Standardize','Column',...
'ImputeFun', @knnimpute);
clusterog.RowPDist='cityblock';
clusterog.ColumnPDist='cityblock';
% saving the figure
plot(clusterog)
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 6 6];
print(HCfigureName,'-dtiff','-r600')
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cell number per cluster figure
ClusterVector=clData;
n=max(ClusterVector)+1;
Step_CellPerCluster = 1;
temp = DataCateg;

cellNumber=zeros(n,1);
ClusterID={};
for i=1:n
    ii=n+1-i;
    [c,cc]=size(temp{str2num(clusterog.RowLabels{ii}),1});
    ClusterID{i}=clusterog.RowLabels{ii};
    cellNumber(i,1)=c;
end
if Step_CellPerCluster==1
    heatmap('cell numbers',ClusterID,cellNumber);
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 1.6 6];
    print(CellNumberTableName,'-dtiff','-r600')
    close all
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The following two functions are used for recording which cells and how
%%% many cells belong to each cluster, and what is the average marker
%%% expression per each cluster.

function output = cell2cluster(input1,input2) 
%input1 being raw dara
%input2 being clustering vector
%output will be a cell with two columns 1 row/cluster; column1 will be the
%cell IDs in each cluster and column2 will be all the marker expressions
    output = {};
    [n1,nn1]=size(input1); [n2,nn2]=size(input2);
    %cl_out = 0; %if 0: no clusterID -1 existing
    % checking if clustering has -1 values
    cl = unique(input2)+1; [c,cc]=size(cl); c1=cl(1);
    if sum(cl==0)>0
        %cl_out=1;
        c1=cl(2);
    end
    for i=c1:cl(end)
        output{i,1}=find((input2+1)==i); [o,oo]=size(output{i,1}); temp=zeros(o,nn1);
        for j=1:o
            temp(j,:)=input1(output{i,1}(j),:);
        end
        output{i,2}=temp;
    end
end


function output = AvgCluster(input1)
%input1 being the cell array that was the output of cell2cluster function
%output 
[n,nn]=size(input1); [m,mm]=size(input1{1,2});
output = zeros(n,mm); % n: cluster num; mm: marker num 
for i=1:n
    output(i,:)=mean(input1{i,2});
end
end