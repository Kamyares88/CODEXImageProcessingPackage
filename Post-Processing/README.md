In the portprocessing step, The following processes will be done on the data:

   1. Reading the raw protein expression in each cell. 
   2. Data normalization (log transformation and compensating the interchannel signal intensity inconsistency).
   3. Performing unsupervised clustering on the data.
   4. Choosing the optimum number of clusters.
   5. Visualizing each cell cluster average marker expression and cell type annotation.
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

The python code "ClusteringImageData.py" in the "MatLab and Python Functions" folder should be opened and ran in python. The results of the clustering will be saved in csv format in the "Post-Processing Output" folder. 

Both K-means and Agglomerative Hierarchichal clustering algorithms require the numbe of clusters as an input. Hence, here, by running "ClusteringImageData.py" we actually run the two algorithms iteratively for 30 number of input clustering numbers (from 1 cluster to 30 clusters). The saved csv result text files are matrices with 30 columns and n number of rows (n=number of cells). Each column represents the result of one clustering. For example column 10, represents the result of clustering the data using 10 number of clusters, meanning that the algorithm has recognized 10 cell clusters in the data. Similarly, column 30, contains the result of cell clustering using 30 number of clusters. in a biology-wise point of view, only one of these columns contains the accurate results and the rest of the columns are suffering from either under-clustering (having distinct cell types merged into one cluster) or over-clustering (having the cells of one cell type recognized as two or more clusters). Hence, it is crucial for us to find out which number of clusters is the most accurate. Thus task is done in the next step.


### Step 4. Choosing the optimum number of clusters

In this step, we use two well-stablished algorithms (Silhouette and Davis Bouldin) to evaluate the quality of clustering and decide which number of clustering is the best among the ones our python code performed for us. Both algorithms numerically assess how similar are the distances of the cells that are in one cluster and compare it with how dissimilar they are from the cells of other clusters. The results of both algorithms will be presented to the user by two plots. In the Silhouette plot, the local maximas and in the Davis Bouldin plot, the local minimas are the ones that the user should focus on in order to find the accurate number of clustering. In most cases, multiple local maxima and minima will be found. If so, the user needs to use their prior knowledge of the number of cell types to shortlist 2-4 candidates of true number of clusters. Then the user should
proceed with cell type detection (step 5). If there are missing known cell types, or merged cell types in one cluster that they know they should be ditinct, then it means there should be more number of clusters. If there are multiple clusters of the same cell types and no cell type is missing, then they should switch to a lower number of clusters.

NOTE: On a 2.6 GHz intel Core i7 processor, the Silhouette cluster evaluation algorithm takes about 10 minutes for a sample of 20,000 cells and 40 different number of clusterings.

```Matlab
eva_Kmeans_sil = ClQC_Silhouette(NormalizedData,'CellClusters_Kmeans.csv');
eva_Kmeans_DB = ClQC_DaviesBouldin(NormalizedData,'CellClusters_Kmeans.csv');

eva_WAggHC_sil = ClQC_Silhouette(NormalizedData,'CellClusters_WAggHC.csv');
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
```
The number of clusters detected by this analysis will be entered by the user and it will be saved in the variavle "BestClusterNum".


### Step 5. Visualizing each cell cluster average marker expression and cell type annotation

At this step, we first make a heatmap of the clusters and their average marker expression. for plotting the heatmap we use the clustergram function in MATLAB which does a hierarchical clustering on the input. The benefit of it is that the function automatically orders the cluster in a way that the similar ones sit close to each other and it also creates a dendogram for the clusters which lets us better recognize the cell types. For example, the macrophages and monocytes always end up being very close to each other in the heatmap. 
Here we recommend the user to either use the K-means algorithm results or the Ward agglomerative clustering. We advise the user to test the two algorithms on a ground truth dataset and see which ones work better on their hand. **In our hand, both algorithms outperformed 4 other algorithms (SPADE, SC3, OPTICS, and Birch) and resulted in more than 95% accuracy in detection of the right cell types.**

```MATLAB
CellCluster_Kmeans=HConClusters(ChannelNames,NormalizedData,'CellClusters_Kmeans.csv',...
        BestClusterNum,'ClustersMarkerExpression_Kmeans',...
        'CellNumberPerCluster_Kmeans');
CellCluster_WAggHC=HConClusters(ChannelNames,NormalizedData,'CellClusters_WAggHC.csv',...
        BestClusterNum,'ClustersMarkerExpression_WAggHC',...
        'CellNumberPerCluster_WAggHC');
```

After annotating cell types, the user needs to enter the name of the cell types on the MATLAB command line and store it in the "CellTypeNames" variable. The order of cell type names should mathc the order of rows on the heatmap. Therefore, if the 5th row of the heatmap is recognized by the user to be a Stromal cell type, the 5th element of the cell array should be named 'Stromal' or any other name attributed to that cell type. The following is an example of entering the name of the cell types:

```MATLAB
%CellTypeNames={'CD4(-)CD8(-)DC','IgM(hi)Stromal','Stromal 1','Stromal 2','Stromal 3','Stromal 4','ERTR(+)Stromal','Vascular','CD8(+)MHCII(+)','Erythroid','Erythroid marginal w Stromal','CD11c(+)Bcell','NKcell','FDC','Bcell','Follicular Macs','Macs','Marginal Zone Macs','No ID','CD4(+)Tcell','Marginal Zone CD4(+)Tcell','CD8(+)Tcell','B220(+)DN Tcell'};
```

Although we tried to optimize the number of clusters, the user might find out that there are still two or more than two rows that should all get the same label (e.g. T cells or B cells). In order to make it possible, the user should enter the cluster number (the number on the right side of each row of the heatmap) in the form of the cell array and save it in a variable named "CellTypeClusters".

```MATLAB
%CellTypeClusters={24,26,20,12,15,21,31,17,7,[30,2],11,32,34,3,[25,5,19,16,1],6,14,9,[28,23],[13,4,33],29,22,10};
```
In the example above, cluster 24 is the only cluster type that the algorithm will recognize as "CD4(-)CD8(-)DC". however clusters 30 and 2 will be both recognized by the algorithm as the same cell type "Erythroids".
Note: The step above is necessary to do even if all the the cell types contain one clusters.

### Step 6. Visualizing cell clusters or cell types superimposed on the fluorescent images
One way to check whether everything so far makes sense, is to superimpose the recognized cell types or individual clusters on the fluorescent images and see whether they are in concert with the images or not. For example, if one superimposes the "B cells" on the image of the CD19 marker, all cells that are positive for CD19 should have been recognized as B cells. This can act as visual QC on the obtained results. In order to do so, the following code must be entered in the command line of MATLAB:

```MATLAB
ClusterPlot({[30,2],[25,5,19,16,1],[13,4,33]},{'r','b','y'},CellCluster_Kmeans,...
    cell_elements,strcat(ParentDIR,InputDIR),'mask.tiff','CD3.tif',...
    'CD3_dots','CD3_shape')
```

In the above code the function ClusterPlot receives the following inputs:

1. a cell array containing the cluster numbers to be visualized. If the user bin some cluster numbers in the form of a vector (e.g. [30,2] or [25,5,19,16,1]), the function will look at all of the bin clusters as the same cell types and will plot all of them with 1 color.

2. a cell array containing strings that represent the color of each cell. User can choose which color each element of the cell array should be plotted with. In MATLAB, colors are represnted with one character that is usually the first letter of the color. 'r':red; 'b':blue; 'Y': Yellow; 'g':Green; 'm': Magenta; 'w': White; 'k': Black.

3. CellCluster_Kmeans: is the variable containing all the clustering results for the K-means algorithm. If you have done all the steps 0 to 5, this variable already exists in your variable list.

4. cell_elements: a cell array containing the pixel-wise information for every single cell. If you have done all the steps 0 to 5, this variable already exists in your variable list.

5. strcat(ParentDIR,InputDIR): Defining the path where the images are stored

6. 'mask.tiff': the name of the segmentation mask file. User should change it to wahtever name that have chosen for the Segmentation mask file. 

7. 'CD3.tif': The name of the fluorescent image that is chosen to superimpose the cells on it. User can change it to name of the any image existing in their dataset. 

8. 'CD3_dots': After running the code two images are produced. one of the images depicts the 'CD3.tif' image with selected cell groups projected on it in the form of small dots at the centroid of the cells. The function will save this image with the name that the user specifies here. 

9. 'CD3_shape': After running the code two images are produced. one of the images depicts the 'CD3.tif' image with selected cell groups projected on it with their exact shapes. The function will save this image with the name that the user specifies here. 


### Step 7. Performing cell-cell interaction analysis

"CellCellX" function is the function that calculates the cell-cell interaction frequencies and plot the results in the form of a heatmap.

```MATLAB
MaskImageName='mask.tiff';
NeighborMat=CellNeighborFinder(MaskImageName,strcat(ParentDIR,InputDIR)); % calculating neighboring cells of each cell
[NeighborMat,IntMat,normIntMat]=CellCellX(CellTypeNames,...
        CellTypeClusters,NormalizedData,NeighborMat,BestClusterNum,...
        'CellClusters_Kmeans.csv','mask.tiff','CellCellInteraction');
    
```


