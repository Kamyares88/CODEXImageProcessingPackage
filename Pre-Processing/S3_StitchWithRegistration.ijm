// Kamyar Esmaeili Pourfarhangi 20191201
// Pre-Processing: Step 3
// This macro performs registering and stitching. It registers the images of adjacent FOVs to 
// 		fix any XY drift due to motorized stage error. 
//---------------------------------------------------------------------------------------------
// Required Pluggin:
// "Stitch Sequence of Grid Images"
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
Dialog.addNumber("MIAcol:", 8,0,3, "Number of Columns in the MIA");
Dialog.addNumber("MIArow:", 7,0,3, "Number of Rows in the MIA");
Dialog.addNumber("Percent Overlap:", 1,0,3, "(%) Overlap between adjacent FOVs");
Dialog.addCheckbox("Batchmode processing", false);
Dialog.show();
MIAcol = Dialog.getNumber();
MIArow = Dialog.getNumber();
Overlap = Dialog.getNumber();
BatchMode = Dialog.getCheckbox();

//---------------------------------------------------------------------------------------------
// Selecting working directory: (Recommended) A folder in the same directory where raw images 
//		are stored.
showMessage("Select Working Directory");
WorkingDIR=getDirectory("Choose a Directory");

// Selecting Source directory: The directory in which the results of Step 2 are saved
showMessage("Select The Source Directory");
SourceDIR=getDirectory("Choose a Directory");
//---------------------------------------------------------------------------------------------

setBatchMode(BatchMode);
for (i=1;i<=MIArow;i++){
	for (j=1;j<=MIAcol;j++){
		Y=i;
		k=(i-1)*MIAcol+j;
		open(SourceDIR+k+".tif");
		r=floor(i/2);
		if (r!=(i/2)) {
			X=j;
		}
		if (r==(i/2)) {
			X=MIAcol+1-j;
		}
		saveAs("Tiff", WorkingDIR+"/Tile_Y"+Y+"_X"+X+".tif");
		close();
	}
}
run("Stitch Sequence of Grids of Images", "grid_size_x="+MIAcol+" grid_size_y="+MIArow+" grid_size_z=1 overlap="+Overlap+" input=["+WorkingDIR+"] file_names=Tile_Y{y}_X{x}.tif rgb_order=rgb output_file_name=TileConfiguration_{zzz}.txt output=["+WorkingDIR+"] start_x=1 start_y=1 start_z=1 start_i=1 channels_for_registration=[Red, Green and Blue] fusion_method=[Linear Blending] fusion_alpha=1.50 regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap");
setBatchMode(false);