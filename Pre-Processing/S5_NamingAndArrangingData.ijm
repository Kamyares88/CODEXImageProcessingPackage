// Kamyar Esmaeili Pourfarhangi 20200604
// Pre-Processing: Step 5
// This macro prepares a dataset for the segmentation step and anotrher dataset for the Post-Processing steps
//---------------------------------------------------------------------------------------------
// Required input:
// CycleNum: The number of cycles in the image dataset
// Blank Cycle number: The number of the blank cycle
// ChannelNum: The number of channels per cycle
// Reference channel: The channel with the same marker imaged in all cycles, usually is DAPI but in rare cases
//		other markers are used (e.g. The original CODEX paper uses CD45 for this purpose)
// Batchmode processing: If checked forces FIJI to process the data in the batchmode
// 
// The second dialog box in this macro asks for the background values at each channel of each cycle except for the reference channel
// 		There is a detailed instructions in the github repository of the package (in the Pre-Processing folder) on how to assess
//		these background values
//---------------------------------------------------------------------------------------------
//Creating a dialog box asking the user to indicate which cycle should be used as the blank cycle
Dialog.create("Please Indicate the Blank cycle");
Dialog.addNumber("CycleNum:", 0,0,3, "Number of Cycles");
Dialog.addNumber("Blank Cycle number:", 0,0,3, "The number of the blank cycle");
Dialog.addNumber("ChannelNum:", 0,0,3, "The number of channels per cycle");
Dialog.addNumber("Reference channel:", 0,0,3, "Usually DAPI channel but can be another marker that is captured in all cycles")
Dialog.addCheckbox("Batchmode processing", false);
Dialog.show();
CycleNum = Dialog.getNumber();
BlankCyc = Dialog.getNumber();
ChannelNum = Dialog.getNumber();
REFch = Dialog.getNumber();
BatchMode = Dialog.getCheckbox();
//
ChannelID=newArray(ChannelNum-1);
j=0;
for (i = 1; i <= ChannelNum; i++) {
	if (REFch==i) {
	} else {
		ChannelID[j]=i;
		j=j+1;
	}
}
//
//Creating another dialog box which will receive the average background expression for each channel of every cycle
Dialog.create("More info...");
for (i = 1; i <=CycleNum; i++) {
	if (i==1) {
		Dialog.addString("Marker used in reference channel:", "...");
		Dialog.addToSameRow();
		Dialog.addCheckbox("Use for segmentation", true);
	}
	if (i!=BlankCyc) {
		j=0;
		Dialog.addString("Marker used in Cyc"+i+"_Ch"+ChannelID[j]+":", "...");
		Dialog.addToSameRow();
		Dialog.addCheckbox("Use for segmentation", true);
		j=j+1;
		if (j<ChannelNum-1) {
			Dialog.addString("Marker used in Cyc"+i+"_Ch"+ChannelID[j]+":", "...");
			Dialog.addToSameRow();
			Dialog.addCheckbox("Use for segmentation", true);
			j=j+1;
		}
		if (j<ChannelNum-1) {
			Dialog.addString("Marker used in Cyc"+i+"_Ch"+ChannelID[j]+":", "...");
			Dialog.addToSameRow();
			Dialog.addCheckbox("Use for segmentation", true);
			j=j+1;
		}
		if (j<ChannelNum-1) {
			Dialog.addString("Marker used in Cyc"+i+"_Ch"+ChannelID[j]+":", "...");
			Dialog.addToSameRow();
			Dialog.addCheckbox("Use for segmentation", true);
			j=j+1;
		}
	}
}
Dialog.show();
MarkerNames=newArray((CycleNum-1)*(ChannelNum-1)+1);
MarkerSeg=newArray((CycleNum-1)*(ChannelNum-1)+1);
MarkerNames[0]=Dialog.getString();
MarkerSeg[0]=Dialog.getCheckbox();
m=0;
for (i = 1; i <=CycleNum; i++) {
	if (i!=BlankCyc) {
		for (j = 1; j <= (ChannelNum-1); j++) {
			el=(m)*(ChannelNum-1)+j;
			MarkerNames[el]=Dialog.getString();
			MarkerSeg[el]=Dialog.getCheckbox();
		}
		m=m+1;
	}
}
//
//// Selecting working directory for saving Segmentation dataset
showMessage("Select Working Directory for Saving Segmentation Dataset");
SegWorkingDIR=getDirectory("Choose a Directory");
//// Selecting working directory for saving Post-Processing dataset
showMessage("Select Working Directory for Saving Post-Processing Dataset");
PostWorkingDIR=getDirectory("Choose a Directory");
//// Selecting Source directory: The working directory of step3 or any directory that the output of step 3 is saved in
showMessage("Select Source Directory");
SourceDIR=getDirectory("Choose a Directory");
// Seeting the batch mode
setBatchMode(BatchMode);
//-----------------------------------------------------------------------------------------------------------
//Saving the segmention and post-processing datasets
open(SourceDIR+"REFch.tif");
rename(MarkerNames[0]);
save(PostWorkingDIR+MarkerNames[0]+".tif");
if (MarkerSeg[0]==false) {
	close();
}
ii=0;
for (i = 1; i <=CycleNum; i++) {
	jj=1;
	if (i!=BlankCyc) {
		for (j = 1; j <= ChannelNum; j++) {
			if (j!=REFch) {
				el=(ii)*(ChannelNum-1)+jj;
				open(SourceDIR+"Cyc"+i+"_ch"+j+".tif");
				rename(MarkerNames[el]);
				save(PostWorkingDIR+MarkerNames[el]+".tif");
				if (MarkerSeg[el]==false) {
					close();
				}
				jj=jj+1;
			}
		}
		ii=ii+1;
	}
}

run("Images to Stack", "name=StackedImage title=[] use");
getDimensions(w, h, channels, slices, frames);
//Switching channels with slices. In the segmentation step, Ilastik needs this modification.
run("Stack to Hyperstack...", "order=xyczt(default) channels="+slices+" slices="+channels+" frames=1 display=Color");
save(SegWorkingDIR+"StackedImage.tif");
