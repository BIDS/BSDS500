function [gPb_orient_ty gPb_orient_sm gPb_orient gPb_orient_lg] = globalPb_im_multiscale(im, outFile, rsz, spb_max_mem)
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

% largest region area for sPb at full size
if nargin<4, spb_max_mem = 300*300; end

if nargin<3, rsz = 1.0; end
if nargin<2, outFile = ''; end

if ((rsz<=0) || (rsz>1)),
    error('resizing factor rsz out of range (0,1]');
end

[tx, ty, nchan] = size(im);
orig_sz = [tx, ty];

%% resize image
im_ty = imresize(im,4,'bicubic');   im_ty = min(max(im_ty,0),1);
im_sm = imresize(im,2,'bicubic');   im_sm = min(max(im_sm,0),1);
im_lg = imresize(im,0.5,'bicubic'); im_lg = min(max(im_lg,0),1);
%im_vlg = imresize(im,0.25,'bicubic'); im_vlg = min(max(im_vlg,0),1);

%% compute cues - standard size
[bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, textons] = det_mPb(im);

%% compute cues - tiny, small, and large sizes
[bg_, cga_, cgb_, tg_, textons_] = det_mPb_sm(im_ty);
[bg0, cga0, cgb0, tg0, textons0] = det_mPb_sm(im_sm);
[bg4, cga4, cgb4, tg4, textons4] = det_mPb_lg(im_lg);
%[bg5, cga5, cgb5, tg5, textons5] = det_mPb_lg(im_vlg);

%% smooth cues
tic;
gtheta = [1.5708    1.1781    0.7854    0.3927   0    2.7489    2.3562    1.9635];
for o = 1 : size(tg1, 3),
    bg_(:,:,o) = fitparab(bg_(:,:,o),3,3/4,gtheta(o));
    bg0(:,:,o) = fitparab(bg0(:,:,o),3,3/4,gtheta(o));
    bg1(:,:,o) = fitparab(bg1(:,:,o),3,3/4,gtheta(o));
    bg2(:,:,o) = fitparab(bg2(:,:,o),5,5/4,gtheta(o));
    bg3(:,:,o) = fitparab(bg3(:,:,o),10,10/4,gtheta(o));
    bg4(:,:,o) = fitparab(bg4(:,:,o),10,10/4,gtheta(o));
    %bg5(:,:,o) = fitparab(bg5(:,:,o),10,10/4,gtheta(o));

    cga_(:,:,o) = fitparab(cga_(:,:,o),5,5/4,gtheta(o));
    cga0(:,:,o) = fitparab(cga0(:,:,o),5,5/4,gtheta(o));
    cga1(:,:,o) = fitparab(cga1(:,:,o),5,5/4,gtheta(o));
    cga2(:,:,o) = fitparab(cga2(:,:,o),10,10/4,gtheta(o));
    cga3(:,:,o) = fitparab(cga3(:,:,o),20,20/4,gtheta(o));
    cga4(:,:,o) = fitparab(cga4(:,:,o),20,20/4,gtheta(o));
    %cga5(:,:,o) = fitparab(cga5(:,:,o),20,20/4,gtheta(o));

    cgb_(:,:,o) = fitparab(cgb_(:,:,o),5,5/4,gtheta(o));
    cgb0(:,:,o) = fitparab(cgb0(:,:,o),5,5/4,gtheta(o));
    cgb1(:,:,o) = fitparab(cgb1(:,:,o),5,5/4,gtheta(o));
    cgb2(:,:,o) = fitparab(cgb2(:,:,o),10,10/4,gtheta(o));
    cgb3(:,:,o) = fitparab(cgb3(:,:,o),20,20/4,gtheta(o));
    cgb4(:,:,o) = fitparab(cgb4(:,:,o),20,20/4,gtheta(o));
    %cgb5(:,:,o) = fitparab(cgb5(:,:,o),20,20/4,gtheta(o));

    tg_(:,:,o) = fitparab(tg_(:,:,o),5,5/4,gtheta(o));
    tg0(:,:,o) = fitparab(tg0(:,:,o),5,5/4,gtheta(o));
    tg1(:,:,o) = fitparab(tg1(:,:,o),5,5/4,gtheta(o));
    tg2(:,:,o) = fitparab(tg2(:,:,o),10,10/4,gtheta(o));
    tg3(:,:,o) = fitparab(tg3(:,:,o),20,20/4,gtheta(o));
    tg4(:,:,o) = fitparab(tg4(:,:,o),20,20/4,gtheta(o));
    %tg5(:,:,o) = fitparab(tg5(:,:,o),20,20/4,gtheta(o));
end
fprintf('Cues smoothing:%g\n', toc);

%% set maximum sPb memory to use
rsz_ty = rsz; while ((rsz_ty*rsz_ty*size(bg_,1)*size(bg_,2)) > spb_max_mem), rsz_ty = 0.5*rsz_ty; end
rsz_sm = rsz; while ((rsz_sm*rsz_sm*size(bg0,1)*size(bg0,2)) > spb_max_mem), rsz_sm = 0.5*rsz_sm; end
rsz_md = rsz; while ((rsz_md*rsz_md*size(bg1,1)*size(bg1,2)) > spb_max_mem), rsz_md = 0.5*rsz_md; end
rsz_lg = rsz; while ((rsz_lg*rsz_lg*size(bg2,1)*size(bg2,2)) > spb_max_mem), rsz_lg = 0.5*rsz_lg; end
%rsz_vlg = rsz; while ((rsz_vlg*rsz_vlg*size(bg3,1)*size(bg3,2)) > spb_max_mem), rsz_vlg = 0.5*rsz_vlg; end

%% compute mPb versions
[mPb_ty, mPb_rsz_ty]   = mPb_from_cues(bg_, bg0, bg1, cga_, cga0, cga1, cgb_, cgb0, cgb1, tg_, tg0, tg1, rsz_ty);
[mPb_sm, mPb_rsz_sm]   = mPb_from_cues(bg0, bg1, bg2, cga0, cga1, cga2, cgb0, cgb1, cgb2, tg0, tg1, tg2, rsz_sm);
[mPb,    mPb_rsz]      = mPb_from_cues(bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, rsz_md);
[mPb_lg, mPb_rsz_lg]   = mPb_from_cues(bg2, bg3, bg4, cga2, cga3, cga4, cgb2, cgb3, cgb4, tg2, tg3, tg4, rsz_lg);
%[mPb_vlg, mPb_rsz_vlg] = mPb_from_cues(bg3, bg4, bg5, cga3, cga4, cga5, cgb3, cgb4, cgb5, tg3, tg4, tg5, rsz_vlg);

%% compute sPb versions
outFile2 = strcat(outFile, '_pbs.mat');
[sPb_ty] = spectralPb(mPb_rsz_ty, orig_sz, outFile2);
delete(outFile2);

outFile2 = strcat(outFile, '_pbs.mat');
[sPb_sm] = spectralPb(mPb_rsz_sm, orig_sz, outFile2);
delete(outFile2);

outFile2 = strcat(outFile, '_pbs.mat');
[sPb] = spectralPb(mPb_rsz, orig_sz, outFile2);
delete(outFile2);

outFile2 = strcat(outFile, '_pbs.mat');
[sPb_lg] = spectralPb(mPb_rsz_lg, orig_sz, outFile2);
delete(outFile2);

%outFile2 = strcat(outFile, '_pbs.mat');
%[sPb_vlg] = spectralPb(mPb_rsz_vlg, orig_sz, outFile2);
%delete(outFile2);

%% compute gPb versions
[gPb_orient_ty gPb_thin_ty]   = gPb_from_cues(bg_, bg0, bg1, cga_, cga0, cga1, cgb_, cgb0, cgb1, tg_, tg0, tg1, mPb_ty, sPb_ty);
[gPb_orient_sm gPb_thin_sm]   = gPb_from_cues(bg0, bg1, bg2, cga0, cga1, cga2, cgb0, cgb1, cgb2, tg0, tg1, tg2, mPb_sm, sPb_sm);
[gPb_orient    gPb_thin]      = gPb_from_cues(bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, mPb,    sPb);
[gPb_orient_lg gPb_thin_lg]   = gPb_from_cues(bg2, bg3, bg4, cga2, cga3, cga4, cgb2, cgb3, cgb4, tg2, tg3, tg4, mPb_lg, sPb_lg);
%[gPb_orient_vlg gPb_thin_vlg] = gPb_from_cues(bg3, bg4, bg5, cga3, cga4, cga5, cgb3, cgb4, cgb5, tg3, tg4, tg5, mPb_vlg, sPb_vlg);
