In the portprocessing step, The following processes will be done on the data:
    1. Reading the raw protein expression in each cell. 
    2. Data normalization (log transformation and compensating the interchannel signal intensity inconsistency).
    3. Performing unsupervised clustering on the data.
    4. Choosing the optimum number of clusters.
    5. Hierarchical clustering on the clusters and visualing each clusters average protein expression.
    6. Annotating each cluster.
    7. Visualizing cell types or cell clusters on the fluorescent images.
    8. Performing cell-cell interaction analysis.
    9. Performing neighborhood analysis based on cells architectural positioning in the tissue (to be added in next versions of the package).

The following walks you through the steps that are needed to perform each of the 9 tasks mentioned above.

### Step 0. Downloading the MATLAB functions of the package and making the working and source directories for the Post-Processing procedure:

A "Matlab and Python Functions" folder is uploaded in the PostProcessing folder of this package. This folder contains all the library of functions that we will be utilizing for processing our imaging data. After clonning this repository into your local device, click on "set path" in your MATLAB, and add this folder into your MATLAB path library. This way MATLAB reads and runs all the functions provided to you in this package. Alternatively you can copy the path of the function folders and enter the following line of code in MATLAB command line:


```MATLAB
% ParentDir is the directory where the folders containing input data and
% functions are placed
ParentDIR = '/Users/Google Drive/CODEXImageProcessingPackage/PostProcessing/';
% Children directories
InputDIR = '/Input Data';
PackageDIR = '/MATLAB and Python Functions';
OutputDIR = '/PostProcessing Output';

addpath(strcat(ParentDIR,PackageDIR));
```
As you may have noticed, we have made a directory named "ParentDIR". This is the directory where the PostProcessing part of the package is clonned into. In addition to the folder "MATLAB and Python Functions" which gets downloaded by the package and contains the functions of the package, we have made two other folders in the "ParentDIR". "Input Data" folder in which we copy all the post-processing dataset that was the output of Step 5 of the pre-processing procedure. The other directory is "PostProcessing Output" which is an empty folder and will be used by the package to deposit all the output results of the postprocessing procedure into. These two folders are introduced to MATLAB as "InputDIR" and "OutputDIR" respectively.

### Step 1. Reading Raw Protein Expression

At this step, the user needs to introduce the name of the input images to the package, so that the reader function could open them one by one and reads protein expression. The cell array "ChannelNames" is the one that will contain the name of the channels. These names should be exactly the same as the marker images located in the "InputDIR" excluding the ".tif".

Another image that is needed by the reader function is the mask image generated in the Segmentation step which is also located in the "InputDIR". We save the name of the mask image in the variable "MaskName". In our sample dataset, the name of the mask image is "mask.tiff".

```MATLAB
ChannelNames={'CD19','CD3e','CD11b','CD54','Cxcl12','CD117','DAPI'};
MaskName='mask.tiff';

[RawSignal,cells,cell_elements]=RawDataReader(ChannelNames,MaskName,strcat(ParentDIR,InputDIR));
```

### Step 2. Data Normalization and standardization

The output of the reader function is a raw read of average gray value of the pixels within the boundary of each cell. However, this values need to be normalized. In our package, four options are provided for normalization, namely Log normalization, Z-score nomralization, Log normalization with cut off and Z-score normalization with cut off. The cut off is the top percentile of the data that will be intentionally set to zero because usually they are false positives. In the example bellow, We have performed a Z-normalization with 2% cut off. All the four introduced normalizing function, process the data of each channel independently from the other channels and do not compensate for the inter-channel variability of the signal.

```MATLAB
ZNormalizedSignal=Znormalizer2(RawSignal,2); 
% Alternatives for primary normalization:
% ZNormalizedSignal=Znormalizer(RawSignal);
% LogNormalizedSignal=Lognormalizer(RawSignal);
% LogNormalizedSignal2=Lognormalizer2(RawSignal,2);
```

In order to remove the inter-channel variability, the following min max normalization is applied to the pre-normalized data. Next, we also save the results in order to use them in python in the next step.

```MATLAB
NormalizedData=MinMaxNormalizer(ZNormalizedSignal);
save('SessionData.mat','ChannelNames','RawSignal','cells','cell_elements','NormalizedData');
    
```

### Step 3. Performing unsupervised clustering

This step is performed via Sklearn package in Python. K-means and Ward Agglomerative Hierarchical clustering are the two unsupervised clustering algorithm that we apply to the single cell protein expression data. The user needs to make sure that the python is installed on their computer and they have a text editor with the capability of running python. We recommend using Spyder for running python. 

The python code "ClusteringImageData.py" in the "MatLab and Python Functions" folder should be opened and ran in python. The results of the clustering willbe saved in csv format in the "Post-Processing Output" folder. 



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


```



