# Segmentation

The segmentation pipeline is based on [IMCSegmentationPipeline](https://github.com/BodenmillerGroup/ImcSegmentationPipeline) which is based on Ilastik and CellProfiler for pixel classification and segmentation, respectively.

## Step 1. Training the pixel classifier

  1. In FIJI, user should open the multichannel stiched image of the tissue (the output of the pre-processing) and randomly select and duplicate 5 to 10 small and same-size locations of it. The small images will be saved in a working directory. We recommend selecting regions that look different morpholically (cell density, cell pattern, corners of the image and middle of the image). The number of selected small images should roughly represent all areas of the original data so that the trained model based on the small images efficiently classifies the entire image. The size of the small images should be at least 200 um square.
  
  2. In Ilastik:
    1. make a new *pixel classification project*. Next, select Raw Data-> Add separate Images-> select all the small images made in step 1. In the *fearure selection* select all the features that are above 1 pixel.
  
    2. In the 
