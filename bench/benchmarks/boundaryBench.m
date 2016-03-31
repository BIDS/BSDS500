function boundaryBench(imgDir, gtDir, pbDir, outDir, nthresh, maxDist, thinpb)
% boundaryBench(imgDir, gtDir, pbDir, outDir, nthresh, maxDist, thinpb)
%
% Run boundary benchmark (precision/recall curve) on dataset.
%
% INPUT
%   imgDir: folder containing original images
%   gtDir:  folder containing ground truth data.
%   pbDir:  folder containing boundary detection results for all the images in imgDir. 
%           Format can be one of the following:
%             - a soft or hard boundary map in PNG format.
%             - a collection of segmentations in a cell 'segs' stored in a mat file
%             - an ultrametric contour map in 'doubleSize' format, 'ucm2' stored in a mat file with values in [0 1].
%   outDir: folder where evaluation results will be stored
%	nthresh	: Number of points in precision/recall curve.
%   MaxDist : For computing Precision / Recall.
%   thinpb  : option to apply morphological thinning on segmentation
%             boundaries before benchmarking.
%
% based on boundaryBench by David Martin and Charless Fowlkes:
% http://www.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/segbench/code/Benchmark/boundaryBench.m
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>

if nargin<7, thinpb = true; end
if nargin<6, maxDist = 0.0075; end
if nargin<5, nthresh = 99; end


iids = dir(fullfile(imgDir,'*.jpg'));
for i = 1:numel(iids),
    evFile = fullfile(outDir, strcat(iids(i).name(1:end-4),'_ev1.txt'));
    if exist('evFile','file'), continue; end
    inFile = fullfile(pbDir, strcat(iids(i).name(1:end-4),'.mat'));
    if ~exist(inFile,'file'),
        inFile = fullfile(pbDir, strcat(iids(i).name(1:end-4),'.png'));
    end
    gtFile = fullfile(gtDir, strcat(iids(i).name(1:end-4),'.mat'));
    evaluation_bdry_image(inFile,gtFile, evFile, nthresh, maxDist, thinpb);
    disp(i);
end

%% collect results
collect_eval_bdry(outDir);

%% clean up
system(sprintf('rm -f %s/*_ev1.txt',outDir));








