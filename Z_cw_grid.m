% 2pool cw-solution for a Z-value grid of (dw,B1)

%   **********************************
%   This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or(at your option) any later version.
%    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%    You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%   CEST sources  Copyright (C) 2014  Moritz Zaiss
%   **********************************
%
% P= struct of system and sequence parameters
% xZspec = frequency offsets in ppm
% returns grid Z_cw_grid(xZspec,B1)

%   Author: Moritz Zaiss  - m.zaiss@dkfz.de
%   Date: 2014/07/25
%   Version for cest sources


function  [Z]=Z_cw_grid(x,B1,dwa,r2a,dwb,kb,fb,r2b,P)

for ii=1:numel(B1)
w_ref=2*pi*P.FREQ;
gamma=267.5153;  
w1 =B1(ii)*gamma;
da=(x(ii)-dwa)*w_ref;
db=(x(ii)-dwb)*w_ref;
theta=atan(w1./da);

%Rex, exchange dependent relaxation in the rotating frame
Rex=Rex_Lorentz(da,w1,db,fb,kb,r2b);

%Reff, R1rho of pure water
Reff=P.R1A*cos(theta).^2 +r2a*sin(theta).^2;

%%
R1rho=Reff+Rex; 
Pz=cos(theta);    % for cw   ; Pz=1;    % for SL
Pzeff=cos(theta); % for cw   ; Pzeff=1; % for SL
Zss=cos(theta).*Pz.*P.R1A./R1rho;

Z(ii,1)= (Pz.*Pzeff*P.Zi -  Zss).*exp(-(R1rho*P.tp)) +Zss;

end;

end


%HyperCESTLimit %JCP paper  negelects (R1B<<kBA, Reff<<R2B)
function Rex=Rex_Hyper_full(da,w1,db,fb,kb,r2b)
ka=kb*fb;
Rex=((ka.*kb.*w1.^2.*((-da+db).^2 + (r2b.*(da.^2 + (ka + kb).^2 + kb.*r2b + w1.^2))./kb))./...
            ((ka + kb).*(db.^2.*w1.^2 + ka.*r2b.*w1.^2) + ...
        (ka + kb).*((da.*db - ka.*r2b).^2 + (db.*ka + da.*(kb + r2b)).^2 + ...
        (ka + kb + r2b).^2.*w1.^2) + (ka + kb + r2b).*(da.^2.*w1.^2 + w1.^4)));
end

%LorentzLimit %NBM paper   negelects (kAB<<kBA, R1B<<kBA, Reff<<R2B)
function Rex=Rex_Lorentz(da,w1,db,fb,kb,r2b)
ka=kb*fb;

REXMAX= ka.*w1^2./(da.^2+w1.^2).*((da-db).^2 +(da.^2+w1.^2).*r2b./kb + r2b.*(kb+r2b));
GAMMA=2*sqrt( (kb+r2b)./kb.*w1.^2 + (kb+r2b).^2);
Rex=REXMAX./((GAMMA./2).^2+db.^2);
end

   