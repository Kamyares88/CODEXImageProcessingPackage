#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr 18 13:09:40 2020

@author: esmaeilipk
"""

import scipy.io
import numpy as np
from sklearn.cluster import KMeans
from sklearn.cluster import AgglomerativeClustering

# Change the ParentDIR to your local directory 
ParentDIR = '/Users/esmaeilipk/Google Drive/PostDoc/ImageProcessing017_PackageDeveloping/PostProcessing/Version 2'
OutputDIR = ParentDIR+'/Post-Processing Output'

DataDIR = OutputDIR+'/SessionData.mat'
mat = scipy.io.loadmat(DataDIR)
Smalldata = mat['NormalizedData']


#Running Kmeans clustering with 1 to 30 clusters
for i in range(1,41):
    if (i==1):
        cl_Kmean30_data = KMeans(n_clusters=i,random_state=1).fit_predict(Smalldata)
    elif (i==2):
        Exp_data = KMeans(n_clusters=i,random_state=1).fit_predict(Smalldata)
        Exp_data = np.concatenate((cl_Kmean30_data.reshape(-1,1),Exp_data.reshape(-1,1)),axis=1)
    else:
        cl_Kmean30_data = KMeans(n_clusters=i,random_state=1).fit_predict(Smalldata)
        Exp_data = np.concatenate((Exp_data,cl_Kmean30_data.reshape(-1,1)),axis=1)
   
SavingDIR=OutputDIR+'/CellClusters_Kmeans.csv'
np.savetxt(SavingDIR, Exp_data, delimiter=',')   # X is an array

# Ward Agglomerative Hierarchical Clustering with 1 to 30 clusters

for i in range(1,41):
    if (i==1):
        cl_WAggHC_data = AgglomerativeClustering(linkage='ward', n_clusters=i).fit(Smalldata)
        cl_WAggHC_data_labels = cl_WAggHC_data.labels_
    elif (i==2):
        cl_WAggHC_data = AgglomerativeClustering(linkage='ward', n_clusters=i).fit(Smalldata)
        Exp_data = cl_WAggHC_data.labels_
        Exp_data = np.concatenate((cl_WAggHC_data_labels.reshape(-1,1),Exp_data.reshape(-1,1)),axis=1)
    else:
        cl_WAggHC_data = AgglomerativeClustering(linkage='ward', n_clusters=i).fit(Smalldata)
        cl_WAggHC_data_labels = cl_WAggHC_data.labels_
        Exp_data = np.concatenate((Exp_data,cl_WAggHC_data_labels.reshape(-1,1)),axis=1)
   
SavingDIR=OutputDIR+'/CellClusters_WAggHC.csv'
np.savetxt(SavingDIR, Exp_data, delimiter=',')   # X is an array

