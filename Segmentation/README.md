# Segmentation

The segmentation pipeline is based on [IMCSegmentationPipeline](https://github.com/BodenmillerGroup/ImcSegmentationPipeline) which is based on Ilastik and CellProfiler for pixel classification and segmentation, respectively.

## Step 1. Preparing the output of the Pre-Processing for Segmentation

## Step 1. Training the pixel classifier

  1. In FIJI, user should open the multichannel stiched image of the tissue (the output of the pre-processing) and randomly select and duplicate 5 to 10 small and same-size locations of it. The small images will be saved in a working directory. We recommend selecting regions that look different morpholically (cell density, cell pattern, corners of the image and middle of the image). The number of selected small images should roughly represent all areas of the original data so that the trained model based on the small images efficiently classifies the entire image. The size of the small images should be at least 200 um square.
  
  2. In Ilastik:
     1. make a new *pixel classification project*. Next, select Raw Data-> Add separate Images-> select all the small images made in step 1. 
     2. In the *fearure selection* select all the features that are above 1 pixel.
     3. In the *Classification*, first add three labels: 1. Nuclei, 2. Cytoplasm/Membrane, 3. Background.
     4. Start labeling the small images with any of the three defined labels. User can switch among the channels (by using the box next *input data*) to fully label every single training image. For example, user can switch to the nuclei image and finish the labeling of all the neuclei based on that. Then by switching to membrane marker channels, user can label the cytoplasm/membrane and also the background which is the areas with no cells. 
     5. In most of the tissues, areas with high cellular density are abundant with cells that are pressed together. The nuclei of these cells usually recognized as one nuclei by most segmentation algorithms. Here, user can find such nuclei and annotate the low gray value border between each two close nuclei so that the classifier would learn that the dim line between two very close nuclei is the border between the two cells. 
     6. User can check the *uncertainities* to find locations within each image that still need more labeling by the user. If uncertainities are low within class regions and high on the border of two classes, then the labeling and subsequently the prediction in that area are efficient. 
     7. Once the classifier is well trained, 
     
