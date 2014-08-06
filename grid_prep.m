% 2pool cw-solution for Z-spectra
%
% P= struct of system and sequence parameters
% xZspec = frequency offsets in ppm
% returns vector Z(xZspec)

%   Author: Moritz Zaiss  - m.zaiss@dkfz.de
%   Date: 2013/07/04 
%   Version for Jerschow Lab

function  [x, B1out]=grid_prep(xZspec,B1)
x=[];
for ii=1:numel(B1)
x(:,ii)=xZspec;
for jj=1:numel(xZspec)
B1out(jj,ii)=B1(ii);
end;
end;

end
