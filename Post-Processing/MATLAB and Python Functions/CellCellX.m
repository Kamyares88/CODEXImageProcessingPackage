%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Kamyar Esmaeili Pourfarhangi, PhD
%%% Tan Lab
%%% Children's Hospital of Philadelphia
%%% 05/13/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function calculates the number of cell-cell interaction between
%%%     any pair of cell types in the data
%%% Thsi function also plots a heatmap of the cell-cell interaction raw
%%%     data. This data needs to be normalized based on the number of cells
%%%     within each cell type.
%%% 
%%% Inputs:
%%% CellTypeNames:      A string cell array containing the name of the cell
%%%                     types.
%%% CellTypeClusters:   A numeric cell array containing the cluster numbers
%%%                     corresponding to each cell type.
%%% NormSignal:         The name of the matrix containing Normalized data.
%%% NeighborMat:        The matrix containing the neighboring cells
%%%                     information for each cell
%%% ClusterNum:         The number of clusters selected as the best
%%%                     representing the cell types within the data
%%%                     detected by the QC step.
%%% ClusterDataCSV:     Name of the csv file conatining the clustering
%%%                     results
%%% MaskImageName:      The name of the mask image.
%%%                     Example: 'mask.tiff'
%%% CellCellXName:      A string used as the name of the cell-cell
%%%                     interaction heatmap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NeighborMat,IntMat,normIntMat]=CellCellX(CellTypeNames,CellTypeClusters,NormSignal,NeighborMat,ClusterNum,ClusterDataCSV,MaskImageName,CellCellXName)
clData=csvread(ClusterDataCSV);
clData=clData(:,ClusterNum);

DataCateg = cell2cluster(NormSignal,clData);
DataCateg_Avg = AvgCluster(DataCateg);


[tt,t]=size(CellTypeNames);
IntMat=zeros(t); % forming the cell-cell interaction matrix
% 
% WorkingDirectory = cd(SourceDirectory);
% NeighborMat=CellNeighborFinder(MaskImageName);
% SourceDirectory = cd(WorkingDirectory);

for i=1:t
    cls=CellTypeClusters{i}; [nn,n]=size(cls);
    for j=1:n
        cells=DataCateg{cls(j)}; [m,mm]=size(cells);
        for k=1:m
            NHcellNum=NeighborMat(cells(k),2); 
            for l=1:NHcellNum
                NHcell_l=NeighborMat(cells(k),l+2);
                for q=1:ClusterNum
                    if sum(DataCateg{q,1}==NHcell_l)==1
                        flag=1;
                        break
                    end
                end
                if flag==1
                    for h=1:t
                        if sum(CellTypeClusters{h}==q)
                            flag2=1;
                            break
                        end
                    end
                    if flag2==1
                        IntMat(i,h)=IntMat(i,h)+1;
                        flag2=0;
                    end
                    flag=0; 
                end
            end
        end
    end
end

normIntMat=zeros(t);
[d,dd]=size(clData);
clData=clData+1;
for i=1:t
    iNum=sum(sum(clData==CellTypeClusters{i}));
    for j=1:t
       jNum=sum(sum(clData==CellTypeClusters{j}));
       %normIntMat(i,j)=((IntMat(i,j))/sum(sum(IntMat)))/(4*(iNum/d)*4*(jNum/d)); % 4 is average number of cell-cell interaction for each cell.
       normIntMat(i,j)=IntMat(i,j)/(iNum+jNum);
    end
end
heatmap(CellTypeNames,CellTypeNames,IntMat,'Colormap',cool,'ColorScaling','log')
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 6 6];
print(CellCellXName,'-dtiff','-r600')
close all

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The following two functions are used for recording which cells and how
%%% many cells belong to each cluster, and what is the average marker
%%% expression per each cluster.


function output = AvgCluster(input1)
%input1 being the cell array that was the output of cell2cluster function
%output 
[n,nn]=size(input1); [m,mm]=size(input1{1,2});
output = zeros(n,mm); % n: cluster num; mm: marker num 
for i=1:n
    output(i,:)=mean(input1{i,2});
end
end


function output = cell2cluster(input1,input2) 
%input1 being raw dara
%input2 being clustering vector
%output will be a cell with two columns 1 row/cluster; column1 will be the
%cell IDs in each cluster and column2 will be all the marker expressions
    output = {};
    [n1,nn1]=size(input1); [n2,nn2]=size(input2);
    %cl_out = 0; %if 0: no clusterID -1 existing
    % checking if clustering has -1 values
    cl = unique(input2)+1; [c,cc]=size(cl); c1=cl(1);
    if sum(cl==0)>0
        %cl_out=1;
        c1=cl(2);
    end
    for i=c1:cl(end)
        output{i,1}=find((input2+1)==i); [o,oo]=size(output{i,1}); temp=zeros(o,nn1);
        for j=1:o
            temp(j,:)=input1(output{i,1}(j),:);
        end
        output{i,2}=temp;
    end
end

% function NeighborMat=CellNeighborFinder(MaskImageName)
% mask=imread(MaskImageName);
% mask_unique=unique(mask);
% if min(mask_unique)==0
%     [n,nn]=size(mask_unique);
%     mask_unique=mask_unique(2:end);
%     CellNum=n-1;
% else
%     CellNum=n;
% end
% 
% NeighborMat=zeros(CellNum,16);        % 1st column: Cell ID
% NeighborMat(:,1)=mask_unique;   % 2nd column: number of neighbors for each cell
%                                 % 3rd to end column: Neighboring cells IDs
%                          
% [m,mm]=size(mask);
% for i=2:m-1
%     for j=2:mm-1
%         if mask(i,j)~=0
%             CellRow=find(NeighborMat(:,1)==mask(i,j));
%             for ii=i-1:i+1
%                 for jj=j-1:j+1
%                     if (mask(ii,jj)~=0 && mask(ii,jj)~=mask(i,j) && sum(NeighborMat(CellRow,3:end)==mask(ii,jj))==0)
%                         NeighborMat(CellRow,2)=NeighborMat(CellRow,2)+1;
%                         NeighborMat(CellRow,(NeighborMat(CellRow,2)+2))=mask(ii,jj);
%                     end
%                 end
%             end 
%         end
%     end
% end
% 
% 
% end