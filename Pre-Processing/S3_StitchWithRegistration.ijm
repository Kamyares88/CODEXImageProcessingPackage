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
		tile=(Y-1)*MIAcol+X;
		saveAs("Tiff", WorkingDIR+"/Tile_"+tile+".tif");
		close();
	}
}
run("Grid/Collection stitching", "type=[Grid: row-by-row] order=[Right & Down                ] grid_size_x="+MIAcol+" grid_size_y="+MIArow+" tile_overlap="+Overlap+" first_file_index_i=1 directory="+WorkingDIR+" file_names=Tile_{i}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
saveAs("Tiff",WorkingDIR+"/Step3Output_Stitched.tif");
setBatchMode(false);
