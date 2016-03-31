function allBench(imgDir, gtDir, inDir, outDir, nthresh, maxDist, thinpb)
% allBench(imgDir, gtDir, inDir, outDir, nthresh, maxDist, thinpb)
%
% Run boundary and region benchmarks on dataset.
%
% INPUT
%   imgDir: folder containing original images
%   gtDir:  folder containing ground truth data.
%   inDir:  folder containing segmentation results for all the images in imgDir. 
%           Format can be one of the following:
%             - a collection of segmentations in a cell 'segs' stored in a mat file
%             - an ultrametric contour map in 'doubleSize' format, 'ucm2' stored in a mat file with values in [0 1].
%   outDir: folder where evaluation results will be stored
%	nthresh	: Number of points in precision/recall curve.
%   MaxDist : For computing Precision / Recall.
%   thinpb  : option to apply morphological thinning on segmentation
%             boundaries before benchmarking.
%
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>

if nargin<7, thinpb = true; end
if nargin<6, maxDist = 0.0075; end
if nargin<5, nthresh = 99; end


iids = dir(fullfile(imgDir,'*.jpg'));
for i = 1:numel(iids),
    evFile4 = fullfile(outDir, strcat(iids(i).name(1:end-4), '_ev4.txt'));
    if ~isempty(dir(evFile4)), continue; end
    
    inFile = fullfile(inDir, strcat(iids(i).name(1:end-4), '.mat'));
    gtFile = fullfile(gtDir, strcat(iids(i).name(1:end-4), '.mat'));
    evFile1 = fullfile(outDir, strcat(iids(i).name(1:end-4),'_ev1.txt'));
    evFile2 = fullfile(outDir, strcat(iids(i).name(1:end-4), '_ev2.txt'));
    evFile3 = fullfile(outDir, strcat(iids(i).name(1:end-4), '_ev3.txt'));

    evaluation_bdry_image(inFile,gtFile, evFile1, nthresh, maxDist, thinpb);
    evaluation_reg_image(inFile, gtFile, evFile2, evFile3, evFile4, nthresh);
    
    disp(i);
end

%% collect results
collect_eval_bdry(outDir);
collect_eval_reg(outDir);

%% clean up
delete(sprintf('%s/*_ev1.txt', outDir));
delete(sprintf('%s/*_ev2.txt', outDir));
delete(sprintf('%s/*_ev3.txt', outDir));
delete(sprintf('%s/*_ev4.txt', outDir));









