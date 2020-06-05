# Pre-processing Instructions

In the pre-processing step, we apply the following processes to the raw images in order to make them ready for the segmentation step:
* **Selecting the z slices with the best focus** (For every channel of every FOV/tile). [*via S1_FocusSelection_SaveSingleFOVImages.ijm*]. 
  * If the raw images are captured via a Keyence microscope, the user does not neet to modify this macro. Following running the macro, a dialog box pops up (Figure 1) asking the user to enter the number of cycles, the number of columns and rows of the tile matrix and the number of fluorescent channels imaged in each cycle. If raw images are captured in Color format, meaning that each single raw image is a stack of red, green and blue images, the user needs to check the "Raw Images Are in RGB" option. "Batchmode Processing" option, if checked, simply forces the FIJI to perform all the processes in the batch mode. Lastly, the "Multi Region Imaging" option, if selected, informs the software that the region number should be added to the name of each single raw image. The number of region will be asked from the user in another dialog box (Figure 3). The last option, "Assessing focus for all channels?", if checked, will force the macro to do focus selection for all channels. Usually, it is not necessary to do focus selection for all channels because the focal plane of all channels of one cycle in a specific tile is the same. Therefore, by not checking it, the user specifies that they want the focus selection to be performed only on one of the channels. This channel, to which we refer to as the reference channel, should be specified by the user. Therefore, after clicking ok on the dialo box shown in Figure 1, if the user have not checked the last option, another dialog box pops up (Figure 2) asking the user to specifying which channel should be used for focus selection. We recommend to select the channel in which the DAPI is imaged for this purpose.
  
  * After pressing OK in the dialog box shown in Figure 2, another dialog box pops up (Figure 3) in which the user should enter thr number of z-slices captured at every single cycle. Usually, all cycles should have the same number of z-slices captured per FOV, but we experienced conditions where the number of z-slices that a Keyence microscope captures grows from one cycle to another. In any case, the number of z-slices remain the same for all FOVs within one cycle. User can easily find the number of z-slices per cycle by glancing at the name of the images captured at each cycle. Figure 2 also asks the user to "Enter the number of the region" that is being processed in this session. This number should match the number of the region that each raw image has in their name. For example: the region number of image "1_XY01_00001_Z001_CH1.tif" is 1 which is the number after "XY0".
  
  * If the raw images are captured with any microscope other than a Keyence, the user should modify the function "openimage" at line 91 of the macro *S1_FocusSelection_SaveSingleFOVImages.ijm*. This function follows the naming format of the Keyence software which is *ROI#_Tile#_Z slice#_Chanel#.tif*. (For example: 1_00012_10_CH2.tif).
  
    Figure 1 
    ![](Images/Figure%201.png) 
    
    Figure 2 
    ![](Images/Figure%202.png)
    
    Figure 3
    ![](Images/Figure%203.png) 

This macro also requires the user to browse for a working directory. This is the directory in which the macro will save all the output images. This directory will be used by the next macro *S2_RegistInPlace_SaveMultiCycleImagesPerFOV.ijm* as the source directory.

While running, the macro frequently asks the user to browse the directory in which the raw images of each cycle are located. This way the user has the freedom of having the raw images of each cycle saved in various locations (e.g. external hard drives) and still process all of them in one run of this macro.


* **Registering images of the same tile through all the cycles and saving multichannel_multicycle hyperstacks per each tile.** [*via S2_RegistInPlace_SaveMultiCycleImagesPerFOV.ijm*].
  * Following running this macro, a dialog box pops up (Figure 4) asking the user to again enter the number of cycles, columns and rows of the tile matrix and the number of channels. Here, if the user prefers to do the processing in the batch more, they can select option "Batchmode processing."

    Figure 4
    ![](Images/Figure%204.png) 


  * Next, another dialog box pops up (Figure 5) asking the user to enter the name of each channel as well as choosing which channel should be used for registering in-place.  
  
    Figure 5
    ![](Images/Figure%205.png) 
    
  * Next, the user is asked to browse for the working directory. This is the directory in which results of this step will be saved.
  
  * Next, the user is asked to browse for a source directory. This is the directory in which the results of Step 1 are saved.
  
* **Stitching the tiles together** [*via S3_StitchWithRegistration.ijm*]
  * Following running this macro, a dialog box pops up (Figure 6) asking the user to enter the number of columns and rows of the tile matrix as well as the overlap percentage between the adjacent tiles. Here, if the user prefers to do the processing in the batch more, they can select option "Batchmode processing."
  
    Figure 6
    ![](Images/Figure%206.png) 
    
  * Next, the user is asked to browse for the working directory. This is the directory in which results of this step will be saved.
  
  * Next, the user is asked to browse for a source directory. This is the directory in which the results of Step 2 are saved.
  

* **Performing Background Subtraction** [*Via S4_BackgroundSubtraction.ijm*]
  * Following running this macro, a dialog box pops up (Figure 7) asking the user to enter the total number of cycles to be processed, "CycleNum," the blank cycle number, total number of channels per each cycle, "ChannelNum," and the channel number of the reference channel. The reference channel is the fluorescent channel that has imaged the same marker in all cycles. In most cases, DAPI is the reference channel, but in some cases it can be another channel. In this package's sample dataset, the reference channel is DAPI, hence the reference channel number is 1. Here, if the user prefers to do the processing in the batch more, they can select option "Batchmode processing."
  
    Figure 7
    ![](Images/Figure%207.png) 
    
  * Next, another dialogbox pops asking the user to enter the average gray value of the background in each and every channel of every cycle except for the reference channel (Figure 8). This values are very important for performing an accurate background subtraction. For recording these values the user should open the output of step 3 and finds a region in the image where there is no tissue (Figure 9), or in case that such region does not exist, finding a region in each of the fluorescent channels where the cells are not positive for that marker. After finding these locations, the user will draw a rectangle on these regions in both the blank cycles and the marker cycles. The rectangles need to be the same size and on exact same locations. The user can utilize ROI manager under tools in order to save the drawn rectangle and impose it on another image. Next, by selecting Analyze>measure, the user will measure average signal intensity of the specified region by the rectangle in every channel.
  
    Figure 8
    ![](Images/Figure%208.png)

    Figure 9
    ![](Images/Figure%209.png)

  * Next, the user is asked to browse for the working directory. This is the directory in which results of this step will be saved.
  
  * Next, the user is asked to browse for a source directory. This is the directory in which the results of Step 3 are saved.
  
At the end of this step, single channel images of the blank cycles as well as background subtracted images of each marker are saved in the working directory.

* **Saving the dataset for segmentation and post-processing** [*Via S5_NamingAndArrangingData.ijm*]
  * Following running this macro, a dialog box pops up which is identical to the first dialog box poped up when running the previous step (Figure 7).
  
  * Next, another dialog box pops up (Figure 10), in which the user is asked to enter the marker name correponding to the reference channel (In the case of the sample data, DAPI) and the rest of the channels imaged in the non-blank cycles. User can type in the name of the markers (e.g. CD19). For cell segmentation of the images, one might not need to use all of the images. In this case the user may uncheck any of the images that they decide to drop. The segmentation dataset will only include those images that have been checked at this step. 
  
    Figure 10
    ![](Images/Figure%2011.png)

  * Next, the user is asked to browse for the working directory in which the segmentation dataset will be saved. 
  
  * Next, the user is asked to browse for the working directory in which the post-processing dataset will be saved.
  
  * Next, the user is asked to browse for a source directory. This is the directory in which the results of Step 4 are saved.
  
  
  
**At this point the Pre-processing step is over and the user may navigate to the segmentation step.**
  

