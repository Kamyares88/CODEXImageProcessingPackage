%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kamyar Esmaeili Pourfarhangi, PhD
%%% Tan Lab
%%% Children's Hospital of Philadelphia
%%% 05/13/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This scans the entire mask image to find which cells have direct
%%%     interaction with each other. Direct interaction is defined as
%%%     sharing borders between two adjacent cells.
%%% 
%%% Inputs:
%%% MaskImageName:        The name of the mask image.
%%%                       Example: 'mask.tiff'
%%% SourceDirectory:      A string pointing to the directory where the mask
%%%                       image is located.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NeighborMat=CellNeighborFinder(MaskImageName,SourceDirectory)
WorkingDirectory = cd(SourceDirectory);
mask=imread(MaskImageName);
mask_unique=unique(mask);
if min(mask_unique)==0
    [n,nn]=size(mask_unique);
    mask_unique=mask_unique(2:end);
    CellNum=n-1;
else
    CellNum=n;
end

NeighborMat=zeros(CellNum,16);        % 1st column: Cell ID
NeighborMat(:,1)=mask_unique;         % 2nd column: number of neighbors for each cell
                                      % 3rd to end column: Neighboring cells IDs
                         
[m,mm]=size(mask);
for i=2:m-1
    for j=2:mm-1
        if mask(i,j)~=0
            CellRow=find(NeighborMat(:,1)==mask(i,j));
            for ii=i-1:i+1
                for jj=j-1:j+1
                    if (mask(ii,jj)~=0 && mask(ii,jj)~=mask(i,j) && sum(NeighborMat(CellRow,3:end)==mask(ii,jj))==0)
                        NeighborMat(CellRow,2)=NeighborMat(CellRow,2)+1;
                        NeighborMat(CellRow,(NeighborMat(CellRow,2)+2))=mask(ii,jj);
                    end
                end
            end 
        end
    end
end
SourceDirectory = cd(WorkingDirectory);
