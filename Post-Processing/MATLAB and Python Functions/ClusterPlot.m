%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kamyar Esmaeili Pourfarhangi, PhD
%%% Tan Lab
%%% Children's Hospital of Philadelphia
%%% 05/13/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function visualizes one or multiple cell types or cell clusters by
%%%     plotting them and superimposing them on a fluorescent channel or on
%%%     a black background. Cells can be shown in the form of small dots
%%%     projected at the center of the cell or as the cell shapes.
%%% Inputs:
%%% ClArray:            is an array of cluster numbers
%%%                     example: ClArray={1,12,[3,5 9]}; in this case,
%%%                     three different visualization will be superimposed
%%%                     on one plot because cell array has 3 elements. The
%%%                     third element of the ClArray will be treated as sum
%%%                     of all the cells that clusters 3, 5, and 9 include.
%%% ColorGroup:         A cell aray containing color strings to be asigned
%%%                     to each bundle of cell clusters
%%%                     Example: ColorGroup = {'r','g','b'};
%%% CellCluster:        Output of Step 5 of the package:
%%%                     Example: CellCluster_Kmeans or CellCluster_WAggHC
%%% cell_elements:      One of the ourputs of the RawRead function at step
%%%                     1 of the post-processing pipeline saved with the 
%%%                     same name. It contains the pixel elements 
%%%                     representing each and every single cell
%%% SourceDirectory:    A string containing the directory of the input data
%%% MaskImageName:      A string containing the name of the mask image
%%%                     Example: 'mask.tiff'
%%% BG:                 This variable can be either 0 or a name of the
%%%                     channel which the user wnats to use as a background
%%%                     0:          Black background
%%%                     'B220.tif': The image will be used as the
%%%                     background.
%%% ImageName_Dot:      A string which will be used as the name of the
%%%                     dot-projected image
%%% ImageName_Shape:    A string which will be used as the name of the
%%%                     cell shape-projected image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ClusterPlot(ClArray,ColorGroup,CellCluster,cell_elements,...
    SourceDirectory,MaskImageName,BG,ImageName_Dot,ImageName_Shape)
[k,kk]=size(ClArray);
% Recording which cells are being visualized
[Fig,axes1]=CellDotter_BG(SourceDirectory,BG);
for j=1:kk
    [n,nn]=size(ClArray{j});
    CellIDs=[]; % We collect all the cell IDs to be visualized in this vector
    for i=1:nn
        CellIDs=[CellIDs;CellCluster{ClArray{j}(i),1}];
    end
    CellDotter(CellIDs,SourceDirectory,MaskImageName,ColorGroup{j},Fig,axes1)
end
ImageSaver(ImageName_Dot);
[Fig,axes1,y]=CellShaper_BG(SourceDirectory,MaskImageName,BG);
for j=1:kk
    [n,nn]=size(ClArray{j});
    CellIDs=[]; % We collect all the cell IDs to be visualized in this vector
    for i=1:nn
        CellIDs=[CellIDs;CellCluster{ClArray{j}(i),1}];
    end
    CellShaper(y,CellIDs,cell_elements,ColorGroup{j},Fig,axes1)
end
ImageSaver(ImageName_Shape)
end
% This function plots the image with the cell shapes
function CellShaper(n,CellIDs,cell_elements,ColorGroup,Fig,axes1)
[c,cc]=size(CellIDs);
for i=1:c
    CE=cell_elements{CellIDs(i)};
    CE_X=floor((CE-1)/n)+1; CE_Y=CE-n.*(CE_X-1);
    b=boundary(CE_X,CE_Y);
    
    patch('Parent',axes1,'YData',CE_Y(b),'XData',CE_X(b),'FaceAlpha',0.2,...
    'LineWidth',0.5,...
    'FaceColor',ColorGroup,...
    'EdgeColor',[1 1 1]);
end
end

function [Fig,axes1,n]=CellShaper_BG(SourceDirectory,MaskImageName,BG)
WorkingDirectory = cd(SourceDirectory);
mask=imread(MaskImageName); [n,nn]=size(mask); BGblack=uint16(zeros(n,nn)); 

Fig=figure;
axes1 = axes('Parent',Fig);
hold(axes1,'on');
if BG~=0
    BGimage=imread(BG); imshow(BGimage);
else
    imshow(BGblack);
end
SourceDirectory = cd(WorkingDirectory); % transition to WorkingDirectory
end

% This function plots the image with dots representing cells
function CellDotter(CellIDs,SourceDirectory,MaskImageName,ColorGroup,Fig,axes1)
Centroid=CellCentroids(SourceDirectory,MaskImageName);
Cells=Centroid(CellIDs,:);
% plotting the scatter
scatter(Cells(:,1),Cells(:,2),1,'fill',ColorGroup)
axis(axes1,'ij');           % Reversing Y axis
set(axes1,'Color',[0 0 0]); % black background
end

% This function creates a background for the dotplot
function [Fig,axes1]=CellDotter_BG(SourceDirectory,BG)
% Setting up the plot axes
Fig=figure;
axes1 = axes('Parent',Fig);
hold(axes1,'on');
% Adding an image Background
if BG~=0
    WorkingDirectory = cd(SourceDirectory);
    BGimage=imread(BG); imshow(BGimage);
    SourceDirectory = cd(WorkingDirectory);
    hold on
end
end

% This function finds the centroid of cells
function Centroid=CellCentroids(SourceDirectory,MaskImageName)
WorkingDirectory = cd(SourceDirectory); % transition to SourceDirectory
                                        % where mask image is located
mask=imread(MaskImageName);
CellList=unique(mask);
[n,nn]=size(CellList);
if min(CellList)==0
    CellNum=n-1;
else
    CellNum=n;
end
Prop=regionprops(mask);
Centroid=zeros(CellNum,2);
for i=1:CellNum
Centroid(i,:)=Prop(i).Centroid;
end

SourceDirectory = cd(WorkingDirectory); % transition to WorkingDirectory                         
end

% This function saves the image in a high quality fashion
function ImageSaver(Name)
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 20 8];
print(Name,'-dtiff','-r600')
end