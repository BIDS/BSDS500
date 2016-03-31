function [thresh, cntR, sumR, cntP, sumP, cntR_best] = evaluation_reg_image(inFile, gtFile, evFile2, evFile3, evFile4, nthresh)
% function [thresh, cntR, sumR, cntP, sumP, cntR_best] = evaluation_reg_image(inFile, gtFile, evFile2, evFile3, evFile4, nthresh)
%
% Calculate region benchmarks for an image. Probabilistic Rand Index, Variation of
% Information and Segmentation Covering. 
%
% INPUT
%	inFile  : Can be one of the following:
%             - a collection of segmentations in a cell 'segs' stored in a mat file
%             - an ultrametric contour map in 'doubleSize' format, 'ucm2'
%               stored in a mat file with values in [0 1].
%
%	gtFile	:   File containing a cell of ground truth segmentations
%   evFile2, evFile3, evFile4  : Temporary output for this image.
%	nthresh:    Number of scales evaluated. If input is a cell of
%               'segs', nthresh is changed to the actual number of segmentations
%
%
% OUTPUT
%	thresh		Vector of threshold values.
%	cntR,sumR	Ratio gives recall.
%	cntP,sumP	Ratio gives precision.
%
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>


if nargin<5, nthresh = 99; end

load(inFile); 
if exist('ucm2', 'var'),
    ucm = double(ucm2);
    clear ucm2;
elseif ~exist('segs', 'var')
    error('unexpected input in inFile');
end

load(gtFile);
nsegs = numel(groundTruth);
if nsegs == 0,
    error(' bad gtFile !');
end

if exist('segs', 'var')
    if nthresh ~= numel(segs)
        warning('Setting nthresh to number of segmentations');
        nthresh = numel(segs);
    end
    thresh = 1:nthresh; thresh=thresh';
else
    thresh = linspace(1/(nthresh+1),1-1/(nthresh+1),nthresh)';
end

regionsGT = [];
total_gt = 0;
for s = 1 : nsegs
    groundTruth{s}.Segmentation = double(groundTruth{s}.Segmentation);
    regionsTmp = regionprops(groundTruth{s}.Segmentation, 'Area');
    regionsGT = [regionsGT; regionsTmp];
    total_gt = total_gt + max(groundTruth{s}.Segmentation(:));
end

% zero all counts
cntR = zeros(size(thresh));
sumR = zeros(size(thresh));
cntP = zeros(size(thresh));
sumP = zeros(size(thresh));
sumRI = zeros(size(thresh));
sumVOI = zeros(size(thresh));

best_matchesGT = zeros(1, total_gt);

for t = 1 : nthresh,
    
    if exist('segs', 'var')
        seg = double(segs{t});
    else
        labels2 = bwlabel(ucm <= thresh(t));
        seg = labels2(2:2:end, 2:2:end);
    end
    
    [ri voi] = match_segmentations2(seg, groundTruth);
    sumRI(t) = ri;
    sumVOI(t) = voi;
    
    [matches] = match_segmentations(seg, groundTruth);
    matchesSeg = max(matches, [], 2);
    matchesGT = max(matches, [], 1);

    regionsSeg = regionprops(seg, 'Area');
    for r = 1 : numel(regionsSeg)
        cntP(t) = cntP(t) + regionsSeg(r).Area*matchesSeg(r);
        sumP(t) = sumP(t) + regionsSeg(r).Area;
    end
    
    for r = 1 : numel(regionsGT),
        cntR(t) = cntR(t) +  regionsGT(r).Area*matchesGT(r);
        sumR(t) = sumR(t) + regionsGT(r).Area;
    end
    
    best_matchesGT = max(best_matchesGT, matchesGT);

end

% output
cntR_best = 0;
for r = 1 : numel(regionsGT),
    cntR_best = cntR_best +  regionsGT(r).Area*best_matchesGT(r);
end

fid = fopen(evFile2, 'w');
if fid == -1, 
    error('Could not open file %s for writing.', evFile2);
end
fprintf(fid,'%10g %10g %10g %10g %10g\n',[thresh, cntR, sumR, cntP, sumP]');
fclose(fid);

fid = fopen(evFile3, 'w');
if fid == -1, 
    error('Could not open file %s for writing.', evFile3);
end
fprintf(fid,'%10g\n', cntR_best);
fclose(fid);

fid = fopen(evFile4, 'w');
if fid == -1, 
    error('Could not open file %s for writing.', evFile4);
end
fprintf(fid,'%10g %10g %10g\n',[thresh, sumRI, sumVOI]');
fclose(fid);


