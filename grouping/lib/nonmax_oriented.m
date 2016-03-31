% Oriented non-max suppression (2D).
%
% Perform non-max suppression orthogonal to the specified orientation on
% the given 2D matrix using linear interpolation in a 3x3 neighborhood.
%
% A local maximum must be greater than the interpolated values of its 
% adjacent elements along the direction orthogonal to this orientation.
%
% If an orientation is specified per element, then the elements themselves
% may optionally be treated as oriented vectors by specifying a value less 
% than pi/2 for the orientation tolerance.  In this case, neighboring 
% vectors are projected along a line in the local orientation direction and
% the lengths of the projections are used in determining local maxima.
% When projecting, the orientation tolerance is subtracted from the true
% angle between the vector and the line (with a result less than zero
% causing the length of the projection to be the length of the vector).
%
% Non-max elements are assigned a value of zero.
%
% NOTE: The original matrix must be nonnegative.
function nmax = nonmax_oriented(pb, ori, nonmax_ori_tol)

if (nargin < 3), nonmax_ori_tol = pi/8; end
nmax = mex_nonmax_oriented(pb, ori, nonmax_ori_tol);
