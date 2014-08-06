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

function [fitresult, gof] = Multi_B1_Fit(xZspec,B1,z,P)

%% Fit: 'untitled fit 1'.
[xData, yData, zData] = prepareSurfaceData( xZspec, B1, z );

piecewiseZ_cw = @(dwA,R2A,dwB,kBA,fB,R2B,x,y) Z_cw_grid(x,y,dwA,R2A,dwB,kBA,fB,R2B,P);

% Set up fittype and options.
ft = fittype(piecewiseZ_cw, 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf -Inf -Inf -Inf];
opts.StartPoint = [0 1 2 2 0.1 1];
opts.Upper = [Inf Inf Inf Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );
% 
% Plot fit with data.

figure(32), plot3(xData,yData,zData,'.b') ;   hold on;

[Zfit]=Z_cw_grid(xData,yData,fitresult.dwA,fitresult.R2A,fitresult.dwB,fitresult.kBA,fitresult.fB,fitresult.R2B,P);
figure(32), plot3(xData,yData,Zfit,'-r') ;   hold on;

legend('data','fit', 'Location', 'NorthEast' );
% Label axes
xlabel( 'x' );
ylabel( 'B1' );
zlabel( 'Z' );
grid on


