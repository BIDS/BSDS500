addpath benchmarks

clear all;close all;clc;

imgDir = '../BSDS500/data/images/test';
gtDir = '../BSDS500/data/groundTruth/test';
inDir = '../BSDS500/ucm2/test';
outDir = '../BSDS500/ucm2/test_eval';
mkdir(outDir);

% running all the benchmarks can take several hours.
tic;
allBench(imgDir, gtDir, inDir, outDir)
toc;

plot_eval(outDir);