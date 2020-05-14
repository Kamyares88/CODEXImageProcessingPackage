%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kamyar Esmaeili Pourfarhangi, PhD
%%% Tan Lab
%%% Children's Hospital of Philadelphia
%%% 05/13/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function reads raw protein expression for every single cell
%%% Inputs:
%%% ChannelsNames:      is a cell array containing the name of all the 
%%%                     channel tif files
%%%                     example: ChannelNames={'CD19.tif','CD3.tif'};
%%% MaskName:           is a string containing the name of the mask tif 
%%%                     file
%%%                     example: MaskName='Mask.tiff';
%%% SourceDirectory:    The directory in which the image and mask data are
%%%                     locatedTh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [RawSignal,cells,cell_elements]=RawDataReader(ChannelNames,MaskName,SourceDirectory)
[nn,ChannelNum]=size(ChannelNames);     
WorkingDirectory = cd(SourceDirectory); % Saving the current directory into WorkingDirectory and changing
                                        % the directory to SourceDirectory

%%% Reading the mask image
mask = imread(MaskName);

%%% Recording the pixel elements of each cell [Cell_elements]
MaskElements=unique(mask);             
cellb=min(min(mask));                   
if cellb==0                             
    cellb=MaskElements(2);              
end                                    
celle=max(max(mask));                   
tempcellnumber=celle-cellb+1;           
cells=zeros(tempcellnumber,1);          
cell_elements=cell(tempcellnumber,1);   
c=1;                                    
for i=cellb:celle                       
    a=find(mask==i);                    
    if sum(a)>0                         
        cells(c,1)=i;                   
        cell_elements{c}=a;             
        c=c+1;                          
    end                                 
end                                    
z=c-1;                                  
cells=cells(1:z);                       
cell_elements=cell_elements(1:z);       

%%% Reading the raw protein expression for each cell and every channel [RawSig]
RawSignal=[];
for i=1:ChannelNum
    RawSig = Reader(cells,cell_elements,ChannelNames,i);
    RawSignal=[RawSignal,RawSig];
end
SourceDirectory = cd(WorkingDirectory);
end

function output = Reader(cells,cell_elements,ChannelNames,CurrentChannel)
IMAGE=imread(strcat(ChannelNames{CurrentChannel},'.tif'));
[c,cc]=size(cells);
output = zeros(c,1);
for i=1:c
    temp_out=0;
    El=cell_elements{i};
    [e,ee]=size(El);
    for j=1:e
       temp_out = temp_out + double(IMAGE(El(j))); 
    end
    output(i)=temp_out/e; 
   
end

end














