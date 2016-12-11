## A linear power flow model

This code generates the Decoupled Linearized Power Flow (DLPF) and Fast DLPF (FDLPF) model which consider voltage magnitude and reactive power compared to the classical DC power flow model.

The model is proposed in paper: Jingwei Yang, Ning Zhang, Chongqing Kang, Qing Xia,"A State-Independent Linear Power Flow Model with Accurate Estimation of Voltage Magnitude", published on IEEE Transactions on Power Systems.

*test.m is the main program
*DLPF.m generates the Decoupled Linearized Power Flow (DLPF) model
*FDLPF.m generates the Fast Decoupled Linearized Power Flow (FDLPF) model

This source code is distributed in the hope that it will be helpful for your research and personal use. Any commercial/business use should be agreed by the authors of the above mentioned paper.

We do request that publications in which this code is adopted, explicitly acknowledge that fact by citing the above mentioned paper.

*Matpower package is available at http://www.pserc.cornell.edu/matpower/
*test33.m is the IEEE 33 node test feeder. This radial distribution system is modified from http://www.ece.ubc.ca/~hameda/download_files/node_33.m
  
