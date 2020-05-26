// Kamyar Esmaeili Pourfarhangi 20191201
// Pre-Processing: Step 2
// This macro performs registering-in-place. It registers the images of one FOV through all the
//		cycles to fix any XY drift due to motorized stage error. 
//---------------------------------------------------------------------------------------------
// Required Pluggin:
// MultiStackReg: http://bradbusse.net/sciencedownloads.html
//---------------------------------------------------------------------------------------------
// Required input:
// CycleNum: Number of cycles in the dataset to be processed. User will have the oportunity to 
// 		enter this value after running the code.
// MIAcol: Number of columns in the MIA. User will have the opportunity to enter this value a-
//		fter running the code.
// MIArow: Number of Rows in the MIA. User will have the opportunity to enter this value after
//		running the code.
// Channels: The number of fluorescent channels used during the data acquisition. Akoya's lat-
// 		est protocol uses 4 channels of DAPI/488/555/647 or DAPI/488/647/750. 
//---------------------------------------------------------------------------------------------
Dialog.create("Dataset Info");
Dialog.addNumber("CycleNum:", 2,0,3, "Number of Cycles");
Dialog.addNumber("MIAcol:", 7,0,3, "Number of Columns in the MIA");
Dialog.addNumber("MIArow:", 9,0,3, "Number of Rows in the MIA");
Dialog.addNumber("Channels:", 3,0,3, "Number of fluorescent channels");
Dialog.addCheckbox("Batchmode processing", false);
Dialog.show();
CycleNum = Dialog.getNumber();
MIAcol = Dialog.getNumber();
MIArow = Dialog.getNumber();
Channels = Dialog.getNumber();
BatchMode = Dialog.getCheckbox();
// This dialog gets a generic name for each of the channels. "DAPI", "FITC", "Cy3", "Cy5", and "Cy7" are examples 
Dialog.create("Channels Info");
ChannelNamesList=newArray("DAPI","FITC","Cy3","Cy5","Cy7");
for (i = 1; i <= Channels; i++) {
	Dialog.addChoice("Channel "+i, ChannelNamesList);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Use for Registering in place", false);
}
Dialog.show();
ChannelNames=newArray(Channels);
RegisteringCheck=newArray(Channels);
for (i = 1; i <= Channels; i++) {
	j=i-1;
	ChannelNames[j]=Dialog.getChoice();
	RegisteringCheck[j]=Dialog.getCheckbox();
	if (RegisteringCheck[j]) {
		RegisterChannel=j;
	}
}
//---------------------------------------------------------------------------------------------
// Selecting working directory: (Recommended) A folder in the same directory where raw images 
//		are stored.
showMessage("Select Working Directory");
WorkingDIR=getDirectory("Choose a Directory");

// Selecting Source directory: The directory in which the results of Step1 is saved
showMessage("Select The Source Directory");
SourceDIR=getDirectory("Choose a Directory");
//---------------------------------------------------------------------------------------------
// Starting the Process
setBatchMode(BatchMode);
for(f=1; f<=(MIAcol*MIArow); f++){									// loop through FOVs
	for(c=1;c<=CycleNum;c++){										// loop through Cycles
		open(SourceDIR+"Cycle"+c+"_FOV"+f+".tif");
		run("Stack to Hyperstack...", "order=xyczt(default) channels="+Channels+" slices=1 frames=1 display=Color");
		run("Split Channels");
	}
//---------------------------------------------------------------------------------------------		
// Registration
	print ("Regitring-in-Place for Cycle"+c+"_FOV"+f+".tif");

	
	for (i = 1; i <= Channels; i++) {
		run("Images to Stack", "name="+ChannelNames[i-1]+" title=C"+i+" use");
	}
	// Selecting the registering channel for performing the registering
	selectWindow(ChannelNames[RegisterChannel]);
	run("Duplicate...", "title=Mask duplicate");
	run("Subtract Background...", "rolling=20 disable stack");
	run("Enhance Contrast...", "saturated=1 normalize process_all");
	run("MultiStackReg", "stack_1=Mask action_1=Align file_1="+WorkingDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");
	selectWindow("Mask");
	close();

	// Applying the registering to all the channels
	for (i = 1; i <= Channels; i++) {
		run("MultiStackReg", "stack_1="+ChannelNames[i-1]+" action_1=[Load Transformation File] file_1="+WorkingDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
	}
	// Merging the registered channels (either 3 or 4 channels are used in the study)
	if (Channels==3) {
		run("Merge Channels...", "c1="+ChannelNames[0]+" c2="+ChannelNames[1]+" c3="+ChannelNames[2]+" create");
		setSlice(1);
		ColorSet(ChannelNames[0]);
		setSlice(2);
		ColorSet(ChannelNames[1]);
		setSlice(3);
		ColorSet(ChannelNames[2]);
	}else {
		run("Merge Channels...", "c1="+ChannelNames[0]+" c2="+ChannelNames[1]+" c3="+ChannelNames[2]+"  c4="+ChannelNames[3]+" create");
		setSlice(1);
		ColorSet(ChannelNames[0]);
		setSlice(2);
		ColorSet(ChannelNames[1]);
		setSlice(3);
		ColorSet(ChannelNames[2]);
		setSlice(4);
		ColorSet(ChannelNames[3]);
	}
	saveAs("Tiff", WorkingDIR+f+".tif");
	run("Close All");
}	
setBatchMode(false);
//---------------------------------------------------------------------------------------------
// Functions:
//
// This function assigns the right color to each image depending on their names./
function ColorSet(ChannelName) {
	color=0;
	if (ChannelName=="DAPI") {
		run("Blue");
		color=1;
	}
	if (ChannelName=="FITC") {
		run ("Green");
		color=1;	
	}
	if (ChannelName=="Cy3") {
		run("Red");
		color=1;
	}
	if (ChannelName=="Cy5") {
		run ("Grays");
		color=1;
	}
	if (ChannelName=="Cy7") {
		run ("Yellow");
		color=1;	
	}	
	if (color==0) {
		run("Grays");
	}
}
