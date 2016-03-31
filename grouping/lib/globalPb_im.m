function [gPb_orient, gPb_thin, textons] = globalPb_im(im, outFile, rsz)
% syntax:
%   [gPb_orient, gPb_thin, textons] = globalPb_im(im, outFile, rsz)
%
% description:
%   compute Globalized Probability of Boundary of a color image.
%
% arguments:
%   im:       image
%   outFile:  mat format (optional)
%   rsz:      resizing factor in (0,1], to speed-up eigenvector computation
%
% outputs (uint8):
%   gPb_orient: oriented lobalized probability of boundary.
%   gPb_thin:  thinned contour image.
%   textons
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
% April 2008
if nargin<3, rsz = 1.0; end
if nargin<2, outFile = ''; end

if ((rsz<=0) || (rsz>1)),
    error('resizing factor rsz out of range (0,1]');
end

[tx, ty, nchan] = size(im);
orig_sz = [tx, ty];

% default feature weights
if nchan == 3,
        weights = [0  0  0.0039  0.0050  0.0058  0.0069  0.0040  0.0044  0.0049  0.0024  0.0027  0.0170  0.0074];
else
    weights = [ 0   0    0.0054         0         0         0         0         0         0    0.0048    0.0049    0.0264    0.0090];
end

%% mPb
[mPb, mPb_rsz, bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, textons] = multiscalePb(im, rsz);

%% sPb
outFile2 = strcat(outFile, '_pbs.mat');
[sPb] = spectralPb(mPb_rsz, orig_sz, outFile2);
delete(outFile2);

%% gPb
gPb_orient = zeros(size(tg1));
for o = 1 : size(gPb_orient, 3),
    l1 = weights(1)*bg1(:, :, o);
    l2 = weights(2)*bg2(:, :, o);
    l3 = weights(3)*bg3(:, :, o);

    a1 = weights(4)*cga1(:, :, o);
    a2 = weights(5)*cga2(:, :, o);
    a3 = weights(6)*cga3(:, :, o);

    b1 = weights(7)*cgb1(:, :, o);
    b2 = weights(8)*cgb2(:, :, o);
    b3 = weights(9)*cgb3(:, :, o);

    t1 = weights(10)*tg1(:, :, o);
    t2 = weights(11)*tg2(:, :, o);
    t3 = weights(12)*tg3(:, :, o);

    sc = weights(13)*sPb(:, :, o);

    gPb_orient(:, :, o) = l1 + a1 + b1 + t1 + l2 + a2 + b2 + t2 + l3 + a3 + b3 + t3 + sc;
end

%% outputs
gPb = max(gPb_orient, [], 3);

gPb_thin = gPb .* (mPb>0.05);
gPb_thin = gPb_thin .* bwmorph(gPb_thin, 'skel', inf);

if ~strcmp(outFile,''), save(outFile,'gPb_thin', 'gPb_orient','textons'); end
