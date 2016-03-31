% interactive segmentation gui example
clear all;close all;clc;

%% load example data
% load image
im = double(imread('../data/101087.jpg'))/255;

% load gPb
load('../data/101087_ucm2.mat');
[txb,tyb]=size(ucm2);

% load seeds 
s = imresize(imread('101087_seeds.bmp'),[txb,tyb],'nearest');
seeds = zeros(size(s,1), size(s,2));
seeds((s(:,:,1)==0 & s(:,:,2)==255 & s(:,:,3)==0)) = 1;
seeds((s(:,:,1)==255 & s(:,:,2)==0 & s(:,:,3)==0)) = 2;
seeds = seeds(2:2:end,2:2:end);

% load object annotations (none exist yet)
obj_names = {};

%% run interactive segmentation gui
% return updated seeds and object names
% also return last button clicked either 'prev' or 'next'
[seeds obj_names seg action] = interactive_segmentation(im, ucm2, seeds, obj_names);
