function [Bbus, Pbusinj, Qbusinj, Pfinj] = makeXB(baseMVA, bus, branch)
%   Builds the B matrices and phase shift injections for DLPF power flow.
%   Modified from the 'makeBdc' function in Matpower:
%
%   The bus real power injections are related to bus voltage angles by
%       P = BBUS * Va + PBUSINJ
%       Q = BBUS * Va + QBUSINJ
%   The real power flows at the from end the lines are related to the bus
%   voltage angles by
%       Pf = BF * Va + PFINJ
%   Does appropriate conversions to p.u.
%
%   Example:
%       [Bbus, Bf, Pbusinj, Pfinj] = makeBdc(baseMVA, bus, branch);
%
%   See also DCPF.

%   MATPOWER
%   Copyright (c) 1996-2015 by Power System Engineering Research Center (PSERC)
%   by Carlos E. Murillo-Sanchez, PSERC Cornell & Universidad Autonoma de Manizales
%   and Ray Zimmerman, PSERC Cornell
%
%   $Id: makeBdc.m 2644 2015-03-11 19:34:22Z ray $
%
%   This file is part of MATPOWER.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See http://www.pserc.cornell.edu/matpower/ for more info.

%% constants
nb = size(bus, 1);          %% number of buses
nl = size(branch, 1);       %% number of lines

%% define named indices into bus, branch matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

%% check that bus numbers are equal to indices to bus (one set of bus numbers)
if any(bus(:, BUS_I) ~= (1:nb)')
    error('makeBdc: buses must be numbered consecutively in bus matrix')
end

%% for each branch, compute the elements of the branch B matrix and the phase
%% shift "quiescent" injections, where
%%
%%      | Pf |   | Bff  Bft |   | Vaf |   | Pfinj |
%%      |    | = |          | * |     | + |       |
%%      | Pt |   | Btf  Btt |   | Vat |   | Ptinj |
%%
stat = branch(:, BR_STATUS);                    %% ones at in-service branches
b = stat ./ branch(:, BR_X);                    %% series susceptance
r = stat ./ branch(:, BR_R);                    %% series conductance
tap = ones(nl, 1);                              %% default tap ratio = 1
i = find(branch(:, TAP));                       %% indices of non-zero tap ratios
tap(i) = branch(i, TAP);                        %% assign non-zero tap ratios
b = b ./ tap;
r = r ./ tap;

%% build connection matrix Cft = Cf - Ct for line and from - to buses
f = branch(:, F_BUS);                           %% list of "from" buses
t = branch(:, T_BUS);                           %% list of "to" buses
i = [(1:nl)'; (1:nl)'];                         %% double set of row indices
Cft = sparse(i, [f;t], [ones(nl, 1); -ones(nl, 1)], nl, nb);    %% connection matrix

%% build Bf such that Bf * Va is the vector of real branch powers injected
%% at each branch's "from" bus
Bf = sparse(i, [f; t], [b; -b]);    % = spdiags(b, 0, nl, nl) * Cft;
Rf = sparse(i, [f; t], [r; -r]);    % = spdiags(b, 0, nl, nl) * Cft;
%% build Bbus
Bbus = Cft' * Bf;
Rbus = Cft' * Rf;
%% build phase shift injection vectors
bij = - stat .* branch(:, BR_X)./(branch(:, BR_X).^2+branch(:, BR_R).^2);
gij = stat .* branch(:, BR_R)./(branch(:, BR_X).^2+branch(:, BR_R).^2);
bij=bij./tap;
gij=gij./tap;
Pfinj = -bij .* (-branch(:, SHIFT) * pi/180);      %% injected at the from bus ...
Pbusinj = Cft' * Pfinj;                         %% Pbusinj = Cf * Pfinj + Ct * Ptinj;
Qfinj = -gij .* (-branch(:, SHIFT) * pi/180);      %% injected at the from bus ...
Qbusinj = Cft' * Qfinj;                         %% Pbusinj = Cf * Pfinj + Ct * Ptinj;
