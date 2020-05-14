%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kamyar Esmaeili Pourfarhangi, PhD
%%% Tan Lab
%%% Children's Hospital of Philadelphia
%%% 05/13/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   Controls                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section, serves as a control over the pipeline. The steps whose
%   assigned value is 1 will be ran by the algorithm, and those whose
%   assigned value is set to 0 by the user won't be ran.
% This section allows the user to run the entire code, yet run it step by
%   step, or do some modification on some steps, and only run those steps.
%   At the end of each step, the pipeline saves the results, so once one
%   step is ran and the "SessionData" is saved, that step could always be 
%   bypassed through here. 

Step1=1;    % Reading the raw protein expression
Step2=1;    % Normalizing
Step3=1;    % Clustering
Step4=1;    % Clustering QC and choosing the optimum number of clusters
Step5=1;    % Visualizing clusters' marker expression (HC on clusters)
Step6=1;    % Cell-cell interaction
Step7=1;    % Neighborhood Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ParentDir is the directory where the folders containing input data and
% functions are placed
ParentDIR = '/Users/esmaeilipk/Google Drive/PostDoc/ImageProcessing017_PackageDeveloping/PostProcessing/Version 2';

% Children directories
InputDIR = '/Input Data';
PackageDIR = '/MATLAB and Python Functions';
OutputDIR = '/PostProcessing Output';

% Adding the function folder to the search path of current MATLAB session
addpath(strcat(ParentDIR,PackageDIR));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Reading Raw Protein Expression For Each Cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Step1==1
    ChannelNames={'B220','CD106','CD11b','CD11c','CD16-32',...
        'CD169','CD19','CD21-35','CD27','CD3','CD31',...
        'CD35','CD4','CD44','CD45','CD5','CD71',...
        'CD79b','CD8a','CD90','ERTR7','F4-80','IgD',...
        'IgM','Ly6C','Ly6G','MHCII','NKp46',...
        'TCR','Ter119'};
    MaskName='mask.tiff';
    [RawSignal,cells,cell_elements]=RawDataReader(ChannelNames,MaskName,strcat(ParentDIR,InputDIR));

    save('SessionData.mat','ChannelNames','RawSignal','cells','cell_elements');

else
    load('SessionData.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Normalizing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Step2==1
    % Primary Normalization: Normalizing data at each channel independently
    ZNormalizedSignal=Znormalizer2(RawSignal,2); % Applying Z-score 
                                                 % normalization with 2%
                                                 % CutOff defined
    % Alternatives for primary normalization:
    % ZNormalizedSignal=Znormalizer(RawSignal);
    % LogNormalizedSignal=Lognormalizer(RawSignal);
    % LogNormalizedSignal2=Lognormalizer2(RawSignal,2);
    
    % Secondary Normalization: Compensating between-channel variability
    NormalizedData=MinMaxNormalizer(ZNormalizedSignal); 
    
    save('SessionData.mat','ChannelNames','RawSignal','cells','cell_elements','NormalizedData');
else
    load('SessionData.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Clustering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This step includes performing K-means and Ward Agglomerative Hierarchical
% clusterings on the normalized data.
% The Python code "ClusteringImageData.py" in the "MatLab and Python 
% Functions" folder needs to be ran. The Python code saves the results in 
% csv text files in the "Post-Processing Output" folder.
if Step3==1
    UserResponse='N';
    while UserResponse~='Y'
        UserResponse=input('Please navigate to a python editor and run the code "ClusteringImageData.py" located\n in "MatLab and Python Functions" folder. Did you run it? [Y/N]','s');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Clustering QC and choosing the best number of clusters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we perform a clustering QC
%%% In the Silhouette plot, look for a local maxima in the plot
%%% In the Davis Bouldin plot, look for a local minima in the plot

% In most cases, multiple local maxima and minima will be found. If so, 
% the user needs to use their prior knowledge of the number of clusters to 
% shortlist 2-4 candidates of true number of clusters. Then the user should
% proceed with cell type detection (step 5):
%%% If there are missing known cell types, or merged cell types in one 
%   cluster that they know they should be ditinct, then it means there
%   should be more number of clusters
%%% If there are multiple clusters of the same cell types and no cell type 
%    is missing, then they should switch to a lower number of clusters.

% NOTE: On a 2.6 GHz intel Core i7 processor, the Silhouette cluster 
% evaluation algorithm takes about 10 minutes for a sample of 20,000 cells 
% and 40 different number of clusterings.

if Step4==1
    % QC on Kmeans clustering results
    %eva_Kmeans_sil = ClQC_Silhouette(NormalizedData,'CellClusters_Kmeans.csv');
    eva_Kmeans_sil = ClQC_DaviesBouldin(NormalizedData,'CellClusters_Kmeans.csv');
    eva_Kmeans_DB = ClQC_DaviesBouldin(NormalizedData,'CellClusters_Kmeans.csv');
    % QC on Ward Agglomerative Hierarchical Clustering results
    %eva_WAggHC_sil = ClQC_Silhouette(NormalizedData,'CellClusters_WAggHC.csv');
    eva_WAggHC_sil = ClQC_DaviesBouldin(NormalizedData,'CellClusters_WAggHC.csv');    
    eva_WAggHC_DB = ClQC_DaviesBouldin(NormalizedData,'CellClusters_WAggHC.csv');
    
    % Plotting the QC
    subplot(2,2,1);
    plot(eva_Kmeans_sil);
    title('Silhouette on Kmeans');
    
    subplot(2,2,2);
    plot(eva_Kmeans_DB);
    title('DaviesBouldin on Kmeans');
    
    subplot(2,2,3);
    plot(eva_WAggHC_sil);
    title('Silhouette on WAggHC');
    
    subplot(2,2,4);
    plot(eva_WAggHC_DB);
    title('DaviesBouldin on WAggHC');
    
    prompt='Please enter the best number of clusters: ';
    BestClusterNum = input(prompt);
    
    save('SessionData.mat','ChannelNames','RawSignal','cells',...
        'cell_elements','NormalizedData','BestClusterNum',...
        'eva_Kmeans_sil','eva_Kmeans_DB','eva_WAggHC_sil','eva_WAggHC_DB');
else
    load('SessionData.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5: Visualizing clusters versus marker expression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Step5==1
    CellCluster_Kmeans=HConClusters(ChannelNames,NormalizedData,'CellClusters_Kmeans.csv',...
        BestClusterNum,'ClustersMarkerExpression_Kmeans',...
        'CellNumberPerCluster_Kmeans');
    CellCluster_WAggHC=HConClusters(ChannelNames,NormalizedData,'CellClusters_WAggHC.csv',...
        BestClusterNum,'ClustersMarkerExpression_WAggHC',...
        'CellNumberPerCluster_WAggHC');
    prompt='Please enter the Name of the clusters in the form of a cell array: ';
    CellTypeNames = input(prompt);
    %{'CD4(-)CD8(-)DC','IgM(hi)Stromal','Stromal 1','Stromal 2','Stromal 3','Stromal 4','ERTR(+)Stromal','Vascular','CD8(+)MHCII(+)','Erythroid','Erythroid marginal w Stromal','CD11c(+)Bcell','NKcell','FDC','Bcell','Follicular Macs','Macs','Marginal Zone Macs','No ID','CD4(+)Tcell','Marginal Zone CD4(+)Tcell','CD8(+)Tcell','B220(+)DN Tcell'}
    prompt='Please enter the cluster number of each cell type in the form of a cell array: ';
    CellTypeClusters = input(prompt);
    %{24,26,20,12,15,21,31,17,7,[30,2],11,32,34,3,[25,5,19,16,1],6,14,9,[28,23],[13,4,33],29,22,10};
    
    save('SessionData.mat','ChannelNames','RawSignal','cells',...
        'cell_elements','NormalizedData','BestClusterNum',...
        'eva_Kmeans_sil','eva_Kmeans_DB','eva_WAggHC_sil','eva_WAggHC_DB',...
        'CellCluster_Kmeans','CellCluster_WAggHC','CellTypeNames','CellTypeClusters');
else
    load('SessionData.mat');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualizing cell clusters on images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we have the oportunity of visualing cell clusters of interest on the
% images to visually confirm the cell tye asignment
ClusterPlot({[30,2],[25,5,19,16,1],[13,4,33]},{'r','b','y'},CellCluster_Kmeans,...
    cell_elements,strcat(ParentDIR,InputDIR),'mask.tiff','CD3.tif',...
    'CD3_dots','CD3_shape')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 6: Cell-Cell Interaction Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Step6==1
    MaskImageName='mask.tiff';
    NeighborMat=CellNeighborFinder(MaskImageName,strcat(ParentDIR,InputDIR));
    [NeighborMat,IntMat,normIntMat]=CellCellX(CellTypeNames,...
        CellTypeClusters,NormalizedData,NeighborMat,BestClusterNum,...
        'CellClusters_Kmeans.csv','mask.tiff','CellCellInteraction');
    
    save('SessionData.mat','ChannelNames','RawSignal','cells',...
        'cell_elements','NormalizedData','BestClusterNum',...
        'eva_Kmeans_sil','eva_Kmeans_DB','eva_WAggHC_sil','eva_WAggHC_DB',...
        'CellTypeNames','CellTypeClusters','NeighborMat','IntMat',...
        'normIntMat');
else
    load('SessionData.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 7: Neighborhood Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% to be added.






