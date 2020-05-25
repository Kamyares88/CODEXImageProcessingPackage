# CODEXImageProcessingPackage

CODEX Image Processing Package is developed to perform all the steps of processing of the multiplexed imaging data from raw images to deep analysis such as cell-cell interaction and Neighborhood analysis.

The procedure is divided into three steps
1. Pre-processing steps: in which raw images will be registered and stitched together. 
2. Segmentation step: in which Ilastik and cell profiler will be uzed to perform segmentation on the images
3. Postprocessing steps: in wihch the segmentation mask will be used to read the single cell protein expression, cell type calling and performing cell-cell interaction and neighborhod analysis. 

The package includes 1 folder per each of these steps. In addition, the foder data includes a small data set that the package can be tested with. 

