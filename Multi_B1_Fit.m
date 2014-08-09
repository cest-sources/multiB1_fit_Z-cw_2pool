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

function [fitresult, gof] = Multi_B1_Fit(xdw,yB1,Z,P)

% create fit function of depending variables
piecewiseZ_cw = @(dwA,R2A,dwB,kBA,fB,R2B,x,y) Z_cw_grid(x,y,dwA,R2A,dwB,kBA,fB,R2B,P);

if license('test','curve_fitting_toolbox')
% Set up fittype and options.
ft = fittype(piecewiseZ_cw, 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf -Inf -Inf -Inf];
opts.StartPoint = [0 1 2 2 0.1 1];
opts.Upper = [Inf Inf Inf Inf Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( [xdw, yB1], Z, ft, opts );
% 
elseif license('test','optimization_toolbox')
    error('Code for optimization toolbox not yet implemented');
%     xyData = {xData,yData};
%     
%     [x,resnorm,~,exitflag,output] = lsqcurvefit(piecewiseZ_cw,[0 1 2 2 0.1 1],xyData,zData)
%     
%     fitresult.dwA=x(1);
%     fitresult.R2A=x(2);
%     fitresult.dwB=x(3);
%     fitresult.kBA=x(4);
%     fitresult.fB =x(5);
%     fitresult.R2B=x(6);
else
    error('You dont have the fitting or optimization toolbox');
end;

% Plot fit with data.

figure(32),  plot3(xdw,yB1,Z,'.b') ;   hold on; view(180, 0);

[Zfit]=Z_cw_grid(xdw,yB1,fitresult.dwA,fitresult.R2A,fitresult.dwB,fitresult.kBA,fitresult.fB,fitresult.R2B,P);
figure(32), plot3(xdw,yB1,Zfit,'-r') ;   hold on; 
legend('data','fit', 'Location', 'NorthEast' );


%label axes
if license('test','curve_fitting_toolbox')
    
    
    
    coeff_names=coeffnames(fitresult);
    coeffs=coeffvalues(fitresult);
    coeffconf=confint(fitresult,0.95);
    out{1} = '\Delta\omega [ppm]';
    for ii=1:numel(coeffs)
        out{ii+1} = (sprintf('%s=%.5f+-%.5f  (real: %.5f)',coeff_names{ii},coeffs(ii),coeffconf(2,ii)-coeffs(ii),P.(coeff_names{ii})));
    end;
    xlabel(out); grid off;
    set(gca,'XDir','reverse'); zlabel('Z(\Delta\omega)'); set(gca,'zLim',[0 1]); view(180, 0);
    
    
    
elseif license('test','optimization_toolbox')
    
    error('Code for optimization toolbox not yet implemented');
    
else
    
    error('You dont have the fitting or optimization toolbox');
    
end;


