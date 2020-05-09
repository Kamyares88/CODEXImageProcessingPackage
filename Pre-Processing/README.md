# Pre-processing Instructions

In the pre-processing step, we apply the following processes to the raw images in order to make them ready for the segmentation step:
* **Selecting the z slice with the best focus** (For every channel of every FOV/tile). [*via S1_FocusSelection_SaveSingleFOVImages.ijm*]. 
  * If the raw images are captured via a Keyence microscope, the user does not neet to modify this macro. Following running the macro, a dialog box pops up (Figure 1) asking user to enter the number of cycles, the number of columns and rows of the tile matrix, number of channels and the number of Z slices per tile. If raw images are captured in Color format, meaning that each single raw image is stack of red, green and blue images, the user needs to check the "Raw Images Are in RGB" option.
  
  * If the raw images are captured with any microscope other than a Keyence, the user should modify the function "openimage" at line 91 of the macro *S1_FocusSelection_SaveSingleFOVImages.ijm*. This function follows the naming format of the Keyence software which is *ROI#_Tile#_Z slice#_Chanel#.tif*. (For example: 1_00012_10_CH2.tif).
  
    Figure 1 
    ![](Images/Figure%201.png) 

This macro also requires the user to brows for a working directory. This is the directory in which the macro will save all the output images. This directory will be used by the next macro *S2_RegistInPlace_SaveMultiCycleImagesPerFOV.ijm* as the source directory.


* **Registering images of the same tile through all the cycles and saving multichannel_multicycle hyperstacks per each tile.** [*via S2_RegistInPlace_SaveMultiCycleImagesPerFOV.ijm*].
  * Following running this macro, a dialog box pops up (Figure 2) asking the user to again enter the number of cycles, columns and rows of the tile matrix and the number of channels.

    Figure 2
    ![](Images/Figure%202.png) 


  * Next, another dialog box pops up (Figure 3) asking the user to enter the name of each channel as well as choosing which channel should be used for registering.  
  
    Figure 3
    ![](Images/Figure%203.png) 
    
  * Next, the user is asked to brows for the working directory. This is the directory in which results of this step will be saved.
  
  * Next, the user is asked to brows for a source directory. This is the directory in which the results of Step 1 are saved.
  
* **Stitching the tiles together** [*via S3_StitchWithRegistration.ijm*]
  * Following running this macro, a dialog box pops up (Figure 4) asking the user to enter the number of columns and rows of the tile matrix as well as the overlap percentage between the adjacent tiles.
  
    Figure 4
    ![](Images/Figure%204.png) 
    
  * Next, the user is asked to brows for the working directory. This is the directory in which results of this step will be saved.
  
  * Next, the user is asked to brows for a source directory. This is the directory in which the results of Step 1 are saved.
