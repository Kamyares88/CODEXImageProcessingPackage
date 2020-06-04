// Kamyar Esmaeili Pourfarhangi 20200603
// Pre-Processing: Step 4
// This macro performs the background subtraction  
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
// Seeting the batch mode
setBatchMode(BatchMode);
//Creating another dialog box which will receive the average background expression for each channel of every cycle
Dialog.create("Entering Background read for each channel");
for (i = 1; i <=CycleNum; i++) {
	j=0;
	Dialog.addNumber("Cycle "+i+":   ch"+ChannelID[j]+"", 0,0,5, "");
	j=j+1;
	if (j<ChannelNum-1) {
		Dialog.addToSameRow();
		Dialog.addNumber("ch"+ChannelID[j]+"", 0,0,5, "");
		j=j+1;
	}
	if (j<ChannelNum-1) {
		Dialog.addToSameRow();
		Dialog.addNumber("ch"+ChannelID[j]+"", 0,0,5, "");
		j=j+1;
	}
	if (j<ChannelNum-1) {
		Dialog.addToSameRow();
		Dialog.addNumber("ch"+ChannelID[j]+"", 0,0,5, "");
		j=j+1;
	}
}
Dialog.show();
GrayValues=newArray(CycleNum*(ChannelNum-1));
for (i = 0; i <CycleNum; i++) {
	for (j = 0; j < (ChannelNum-1); j++) {
		el=(i)*(ChannelNum-1)+j;
		GrayValues[el]=Dialog.getNumber();
	}
}
//// Selecting working directory: Make a new folder for Step 4
showMessage("Select Working Directory");
WorkingDIR=getDirectory("Choose a Directory");
//// Selecting Source directory: The working directory of step3 or any directory that the output of step 3 is saved in
showMessage("Select Source Directory");
SourceDIR=getDirectory("Choose a Directory");
// openning the output of Step3
open(SourceDIR+"Step3Output_Stitched.tif");
rename("Image");
//------------------------------------------------------------------------------------
//Making single images of the blank cycle
for (i = 1; i <=ChannelNum ; i++) {
	run("Duplicate...", "title=Blank_ch"+i+" duplicate channels="+i+" slices="+BlankCyc+"");
	if (i==REFch) {
		saveAs("Tiff", WorkingDIR+"REFch.tif");
		close();
	} else {
		saveAs("Tiff", WorkingDIR+"Blank_ch"+i+".tif");
		close();
	}
}
//Making single images of non-blank cycles
for (j = 1; j <=CycleNum ; j++) {
	h=0;
	if (j!=BlankCyc) {
		for (i = 1; i <=ChannelNum; i++) {
			run("Duplicate...", "title=Cyc"+j+"_ch"+i+" duplicate channels="+i+" slices="+j+"");
			if (i==REFch) {
				close();
			} else {
				open(WorkingDIR+"Blank_ch"+i+".tif");
				BG_blank=(BlankCyc-1)*(ChannelNum-1)+h;
				BG_image=(j-1)*(ChannelNum-1)+h;
				CompensationRatio=GrayValues[BG_image]/GrayValues[BG_blank];
				selectWindow("Blank_ch"+i+".tif");
				run("Multiply...", "value="+CompensationRatio);
				imageCalculator("Subtract", "Cyc"+j+"_ch"+i+"","Blank_ch"+i+".tif");
				selectWindow("Cyc"+j+"_ch"+i+"");
				saveAs("Tiff", WorkingDIR+"Cyc"+j+"_ch"+i+".tif");
				close();
				close();
				h=h+1;
			}
		}
	}
}

