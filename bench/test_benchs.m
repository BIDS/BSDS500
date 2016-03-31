%% Examples of benchmarks for different input formats
addpath benchmarks
clear all;close all;clc;


%% 1. all the benchmarks for results stored in 'ucm2' format

imgDir = 'data/images';
gtDir = 'data/groundTruth';
inDir = 'data/ucm2';
outDir = 'data/test_1';
mkdir(outDir);
nthresh = 5;

tic;
allBench(imgDir, gtDir, inDir, outDir, nthresh);
toc;

plot_eval(outDir);

%% 2. boundary benchmark for results stored as contour images

imgDir = 'data/images';
gtDir = 'data/groundTruth';
pbDir = 'data/png';
outDir = 'data/test_2';
mkdir(outDir);
nthresh = 5;

tic;
boundaryBench(imgDir, gtDir, pbDir, outDir, nthresh);
toc;

%% 3. boundary benchmark for results stored as a cell of segmentations

imgDir = 'data/images';
gtDir = 'data/groundTruth';
pbDir = 'data/segs';
outDir = 'data/test_3';
mkdir(outDir);

nthresh = 99; % note: the code changes this to the actual number of segmentations
tic;
boundaryBench(imgDir, gtDir, pbDir, outDir, nthresh);
toc;


%% 4. all the benchmarks for results stored as a cell of segmentations

imgDir = 'data/images';
gtDir = 'data/groundTruth';
inDir = 'data/segs';
outDir = 'data/test_4';
mkdir(outDir);
nthresh = 5;

tic;
allBench(imgDir, gtDir, inDir, outDir, nthresh);
toc;


%% region benchmarks for results stored as a cell of segmentations

imgDir = 'data/images';
gtDir = 'data/groundTruth';
inDir = 'data/segs';
outDir = 'data/test_5';
mkdir(outDir);
nthresh = 5;

tic;
regionBench(imgDir, gtDir, inDir, outDir, nthresh);
toc;

