%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kamyar Esmaeili Pourfarhangi, PhD
%%% Tan Lab
%%% Children's Hospital of Philadelphia
%%% 05/13/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function performs a Silhouette clustering ebaluation on the
%%% clustering matrix imported from the csv file saved by python.
%%% Inputs:
%%% NormSignal:         Normalized Data matrix
%%% ClusterDataCSV:     Name of the csv file conatining the clustering
%%%                     results
%%%                     Example: 'CellClusters_Kmeans.csv'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eva = ClQC_Silhouette(NormSignal,ClusterDataCSV)
clData=csvread('CellClusters_Kmeans.csv');
clData=clData+1;
eva = evalclusters(NormSignal,clData,'silhouette');
%plot(eva)
