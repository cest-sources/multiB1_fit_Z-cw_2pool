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
    P.R1A=1/3;          % longitudinal relaxation rate 1/T1 of pool a  [s^-1] 
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
    P.FREQ=300;             % static B0 field [MHz] ~7T ; ppm and µT are used for offsets and B1, therefore gamma=267.5153 is given in Hz.
    P.B1=1;                 % irradiation amplitude [µT]
    P.tp=5;                % pulse duration = saturation time [s]
    P.xZspec= [-4:0.1:4];   % chemical shift of the CEST pool in [ppm] 

    Pstart=P;

%the parameters  P.dwA,P.R2A,P.dwB,P.kBA,P.fB,P.R2B will be optimized
% all other paramters will be set to the above defined value in P
% especially P.R1A is provided to the fit, it needs thus to be measured or assumed

%% OPTION 1: read data from open figure
%  !!! to make sure the script uses the correct figure, close all other !!!
%  !!!!!!! last plot will be read first, adapt your B1 vector !!!!!!!!
% reset data 

Z       = [];
P.xZspec  = [];
clear xxx zzz
obj = get(gca,'Children');         

for ii = 1:numel(obj);
    xxx=get(obj(ii),'XDATA');               
    zzz=get(obj(ii),'YDATA');
    if isrow(xxx)  xxx = xxx';  end
    if isrow(zzz)  zzz = zzz';  end    
    Z       = [Z ; zzz];
    P.xZspec  = [P.xZspec ; xxx];
end
P.B1=[ 6 5 4 3 2];  % these are the B1 values of the individual loaded Z-spectra in reverse order.
[x B1]=grid_prep(xxx,P.B1);
[xData, yData, zData] = prepareSurfaceData( x, B1, B1 );
[Zstart]=Z_cw_grid(xData,yData, P.dwA,P.R2A,P.dwB,P.kBA,P.fB,P.R2B,P);
clear obj i zzz 

%% OPTION 2: get test data from simulation, add some Rician noise
P.B1=[1 2 4];
[x, B1]=grid_prep(P.xZspec ,P.B1);
[xData, yData, zData] = prepareSurfaceData( x, B1, B1 );
[Zstart]=Z_cw_grid(xData,yData, P.dwA,P.R2A,P.dwB,P.kBA,P.fB,P.R2B,P);

Z=ricernd(Zstart,0.01); % add some Rician noise
%% Plot fit of start values and data

figure(1), plot3(xData,yData,Zstart,'r-') ; view(180, 0); hold on;
figure(1), plot3(xData,yData,Z,'.') ;  hold on;
%%
[fitres, gof] = Multi_B1_Fit(xData, yData,Z,P)

coeff_names=coeffnames(fitres);
coeffs=coeffvalues(fitres);
coeffconf=confint(fitres,0.95);

out{1} = '\Delta\omega [ppm]';
for ii=1:numel(coeffs) 
    out{ii+1} = (sprintf('%s=%.5f+-%.5f  (real: %.5f)',coeff_names{ii},coeffs(ii),coeffconf(2,ii)-coeffs(ii),P.(coeff_names{ii})));
end; 
xlabel(out); grid off;
set(gca,'XDir','reverse'); zlabel('Z(\Delta\omega)'); set(gca,'zLim',[0 1]);
