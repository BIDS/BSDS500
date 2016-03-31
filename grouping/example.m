%% Compute global Pb and hierarchical segmentation for an example image.

addpath(fullfile(pwd,'lib'));

%% 1. compute globalPb
clear all; close all; clc;

imgFile = 'data/101087.jpg';
outFile = 'data/101087_gPb.mat';

gPb_orient = globalPb(imgFile, outFile);

%% 2. compute Hierarchical Regions

% for boundaries
ucm = contours2ucm(gPb_orient, 'imageSize');
imwrite(ucm,'data/101087_ucm.bmp');

% for regions
ucm2 = contours2ucm(gPb_orient, 'doubleSize');
save('data/101087_ucm2.mat','ucm2');

%% 3. usage example
clear all;close all;clc;

%load double sized ucm
load('data/101087_ucm2.mat','ucm2');

% convert ucm to the size of the original image
ucm = ucm2(3:2:end, 3:2:end);

% get the boundaries of segmentation at scale k in range [0 1]
k = 0.4;
bdry = (ucm >= k);

% get the partition at scale k without boundaries:
labels2 = bwlabel(ucm2 <= k);
labels = labels2(2:2:end, 2:2:end);

figure;imshow('data/101087.jpg');
figure;imshow(ucm);
figure;imshow(bdry);
figure;imshow(labels,[]);colormap(jet);

%% 4. see also interactive/example_interactive for interactive segmentation.