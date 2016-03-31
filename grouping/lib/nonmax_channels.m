% given NxMxnum_ori oriented channels, compute oriented nonmax suppression
function nmax = nonmax_channels(pb, nonmax_ori_tol)
if (nargin < 2), nonmax_ori_tol = pi/8; end
n_ori = size(pb,3);
oris = (0:(n_ori-1))/n_ori * pi;
[y,i] = max(pb,[],3);
i = oris(i);
y(y<0)=0;
nmax = nonmax_oriented(y,i, nonmax_ori_tol);
