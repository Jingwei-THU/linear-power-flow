% This code generates the Decoupled Linearized Power Flow (DLPF) and Fast
% DLPF (FDLPF) results in the paper:
%
% Jingwei Yang, Ning Zhang, Chongqing Kang, Qing Xia
% "A State-Independent Linear Power Flow Model with Accurate Estimation of Voltage Magnitude"
% published on IEEE Transactions on Power Systems.
%
% This source code is distributed in the hope that it will be helpful for
% your research and personal use. Any commercial/business use should be
% agreed by the authors of the above mentioned paper.
%
% We do request that publications in which this code is adopted, 
% explicitly acknowledge that fact by citing the above mentioned paper.
%
% Matpower package is available at http://www.pserc.cornell.edu/matpower/
%   
clc;clear;
% Define matpower constants
define_constants;
% Load case
mpc = ext2int(loadcase('case33'));
% Set all the generators online
mpc.gen(:, GEN_STATUS) = 1; 
gbus = mpc.gen(:, GEN_BUS);  
% Set all the branches connected. Modify the representation of tab ratio
% from 0 to 1 for more simple coding
mpc.branch(:,BR_STATUS) = 1;
mpc.branch(find(mpc.branch(:,TAP)==0),TAP) = 1;
% Initialize bus info. Same with the code in matpower function 'runpf'.
[ref, pv, pq] = bustypes(mpc.bus, mpc.gen);
mpc.bus([pv;pq],VA) = 0;
mpc.bus(:,VM) = 1;
mpc.bus(gbus,VM) = mpc.gen(:, VG);

% Decoupled Linearized Power Flow (DLPF)
[BusAglAT,BusVolAT,BranchFlowAT] = DLPF(mpc);
% Fast DLPF (FDLPF)
[BusAglATF,BusVolATF,BranchFlowATF] = FDLPF(mpc);
% AC Power flow 
mpopt = mpoption('model','AC');
resultAC = runpf(mpc,mpopt);
BusVolAC = resultAC.bus(:,VM);
BusAglAC = resultAC.bus(:,VA);
BranchFlowAC = (resultAC.branch(:,PF)-resultAC.branch(:,PT))/2;

% Plot bus voltage results (example)
n = size(mpc.bus,1);m = size(mpc.branch,1);
plot(1:n,BusVolAC,'r-','LineWidth',0.6);hold on;
plot(1:n,BusVolAT,'b-','LineWidth',0.6);hold on;
plot(1:n,BusVolATF,'k-o','LineWidth',0.6);
legend('ACPF','DLPF','FDLPF');
xlabel('Node');
ylabel('Voltage Magnitude');
title('Voltage Magnitude Comparison');