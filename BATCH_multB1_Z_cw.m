%% analytic Z-spectra
%   Date: 2014/08/01
%   Version for CEST-sources.de
%   Author: Moritz Zaiss  - m.zaiss@dkfz.de
%   CEST sources  Copyright (C) 2014  Moritz Zaiss
%   **********************************
%   This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or(at your option) any later version.
%    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%    You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%   **********************************
%
% the fit methods requires the MATLAB curve fitting toolbox.
% a version for the optimization toolbox is under construction.

%% SETUP
clearvars P  Pstart
clc
% setup pool system parameters
%water pool 'a'
P.R1A=1/2.85;          % longitudinal relaxation rate 1/T1 of pool a  [s^-1]
P.R2A=2;            % transversal relaxation rate 1/T2 of pool a  [s^-1]
P.dwA=0;            % chemical shift of the water pool in [ppm]

% CEST pool 'b'
P.fB=0.0018018;     % proton fraction fB=M0B/M0A, e.g. 50mM creatine in water:  4*50/(2*55.5*1000)=0.0018018;
P.kBA=50;            % exchange rate [s^-1]     % corresponds to creatine at ~ 22°C, pH=6.4 in PBS (Goerke et al.)
P.dwB=1.9;          % chemical shift of the CEST pool in [ppm]
P.R2B=30;           % transversal relaxation rate 1/T2 of pool b  [s^-1]
P.R1B=1;            % longitudinal relaxation rate 1/T1 of pool b  [s^-1]

% setup sequence parameters
P.Zi=1;                 % Z initial, in units of thermal M0, Hyperpol.: 10^4
P.FREQ=400;             % static B0 field [MHz] ~7T ; ppm and µT are used for offsets and B1, therefore gamma=267.5153 is given in Hz.
P.B1=1;                 % irradiation amplitude [µT]
P.tp=10;                % pulse duration = saturation time [s]
P.xZspec= [-4:0.1:4];   % chemical shift of the CEST pool in [ppm]

Pstart=P;

%the parameters  P.dwA,P.R2A,P.dwB,P.kBA,P.fB,P.R2B will be optimized
% all other paramters will be set to the above defined value in P
% especially P.R1A is provided to the fit, it needs thus to be measured or assumed




%% OPTION 1: get test data from simulation, add some Rician noise
xdw = [];   yB1 = [];
P.B1=[0.25 0.5 1 2 4];
for ii = 1:numel(P.B1);   %% create grid (dw,B1)
    xdw       = [xdw ; P.xZspec(:)];
    yB1     = [yB1 ; P.xZspec(:)*0+P.B1(ii)];
end

[Zstart]=Z_cw_grid(xdw,yB1, P.dwA,P.R2A,P.dwB,P.kBA,P.fB,P.R2B,P);
Z=ricernd(Zstart,0.01); % add some Rician noise

% Plot fit of start values and data
figure(1), plot3(xdw,yB1,Zstart,'g-') ; view(180, 0); hold on;
figure(1), plot3(xdw,yB1,Z,'.') ;  hold on; legend ({'start-model','data'});
set(gca,'XDir','reverse'); xlabel('\Delta\omega [ppm]'); zlabel('Z(\Delta\omega)'); set(gca,'zLim',[0 1]);
%% simultaneous multi-B1-Z-spectra fit (requires curve fitting toolbox)
[fitres, gof] = Multi_B1_Fit(xdw, yB1,Z,P);




%% OPTION 2: read data from open figure
%  !!! to make sure the script uses the correct figure, close all other !!!
%  !!!!!!! last plot will be read first, adapt your B1 vector !!!!!!!!
% reset data

Z = [];  xdw = [];   yB1 = []; clear xxx zzz
obj = get(gca,'Children');

P.B1=[ 3 2 1.5 1 0.75 0.5 0.25];  % these are the B1 values of the individual loaded Z-spectra in reverse order.

for ii = 1:numel(obj);
    xfig=get(obj(ii),'XDATA');  % get x data from figure
    zfig=get(obj(ii),'YDATA');  % get Z data from figure
    if isrow(xfig)  xfig = xfig';  end
    if isrow(zfig)  zfig = zfig';  end
    Z           = [Z ; zfig];
    xdw         = [xdw ; xfig];
    yB1         = [yB1 ;  xfig*0+P.B1(ii)];
end

[Zstart]=Z_cw_grid(xdw,yB1, P.dwA,P.R2A,P.dwB,P.kBA,P.fB,P.R2B,P);
clear obj i zzz
% Plot fit of start values and data
figure(1), plot3(xdw,yB1,Zstart,'r-') ; view(180, 0); hold on;
figure(1), plot3(xdw,yB1,Z,'.') ;  hold on;

% simultaneous multi-B1-Z-spectra fit (requires curve fitting toolbox)
[fitres, gof] = Multi_B1_Fit(xdw, yB1,Z,P);








