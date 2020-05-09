# Pre-processing Instructions

In the pre-processing step, we apply the following processes to the raw images in order to make them ready for the segmentation step:
* Selecting the z slice with the best focus (For every channel of every FOV/tile). [*via S1_FocusSelection_SaveSingleFOVImages.ijm*]. 
  * If the raw images are captured via a Keyence microscope, the user does not neet to modify this macro. Following running the macro, a dialog box pops up (Figure 1) asking user to enter the number of cycles, the number of columns and rows of the tile matrix, number of channels and the number of Z slices per tile. If raw images are captured in Color format, meaning that each single raw image is stack of red, green and blue images, the user needs to check the "Raw Images Are in RGB" option.
  
  * If the raw images are captured with any microscope other than a Keyence, the user should modify the function "openimage" at line 91 of the macro *S1_FocusSelection_SaveSingleFOVImages.ijm*. This function follows the naming format of the Keyence software which is *ROI#_Tile#_Z slice#_Chanel#.tif*. (For example: 1_00012_10_CH2.tif).
  
![](Images/Figure%201.png)

 
