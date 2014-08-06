function r = ricernd(Z, sigma)
%
%  http://en.wikipedia.org/wiki/Rice_distribution 
%
dim = size(Z);

x = sigma .* randn(dim) + Z;
y = sigma .* randn(dim);
r = sqrt(x.^2 + y.^2);