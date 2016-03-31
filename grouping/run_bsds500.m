addpath lib;

clear all;close all;clc;

imgDir = '../BSDS500/data/images/test';
outDir = '../BSDS500/ucm2/test';
mkdir(outDir);
D= dir(fullfile(imgDir,'*.jpg'));

tic;
for i =1:numel(D),
    outFile = fullfile(outDir,[D(i).name(1:end-4) '.mat']);
    if exist(outFile,'file'), continue; end
    imgFile=fullfile(imgDir,D(i).name);
    im2ucm(imgFile, outFile);
end
toc;