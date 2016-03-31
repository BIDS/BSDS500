function [thresh,cntR,sumR,cntP,sumP] = evaluation_bdry_image(inFile,gtFile, prFile, nthresh, maxDist, thinpb)
% [thresh,cntR,sumR,cntP,sumP] = boundaryPR_image(inFile,gtFile, prFile, nthresh, maxDist, thinpb)
%
% Calculate precision/recall curve.
%
% INPUT
%	inFile  : Can be one of the following:
%             - a soft or hard boundary map in image format.
%             - a collection of segmentations in a cell 'segs' stored in a mat file
%             - an ultrametric contour map in 'doubleSize' format, 'ucm2'
%               stored in a mat file with values in [0 1].
%
%	gtFile	: File containing a cell of ground truth boundaries
%   prFile  : Temporary output for this image.
%	nthresh	: Number of points in PR curve.
%   MaxDist : For computing Precision / Recall.
%   thinpb  : option to apply morphological thinning on segmentation
%             boundaries.
%
% OUTPUT
%	thresh		Vector of threshold values.
%	cntR,sumR	Ratio gives recall.
%	cntP,sumP	Ratio gives precision.
%
if nargin<6, thinpb = 1; end
if nargin<5, maxDist = 0.0075; end
if nargin<4, nthresh = 99; end

[p,n,e,v]=fileparts(inFile);
if strcmp(e,'.mat'),
    load(inFile);
end

if exist('ucm2', 'var'),
    pb = double(ucm2(3:2:end, 3:2:end));
    clear ucm2;
elseif ~exist('segs', 'var')
    pb = double(imread(inFile))/255;
end


load(gtFile);
if isempty(groundTruth),
    error(' bad gtFile !');
end

if ~exist('segs', 'var')
    thresh = linspace(1/(nthresh+1),1-1/(nthresh+1),nthresh)';
else
    if nthresh ~= numel(segs)
        warning('Setting nthresh to number of segmentations');
        nthresh = numel(segs);
    end
    thresh = 1:nthresh; thresh=thresh';
end

% zero all counts
cntR = zeros(size(thresh));
sumR = zeros(size(thresh));
cntP = zeros(size(thresh));
sumP = zeros(size(thresh));

for t = 1:nthresh,
    
    if ~exist('segs', 'var')
        bmap = (pb>=thresh(t));
    else
        bmap = logical(seg2bdry(segs{t},'imageSize'));
    end
    
    % thin the thresholded pb to make sure boundaries are standard thickness
    if thinpb,
        bmap = double(bwmorph(bmap, 'thin', inf));    % OJO
    end
    
    % accumulate machine matches, since the machine pixels are
    % allowed to match with any segmentation
    accP = zeros(size(bmap));
    
    % compare to each seg in turn
    for i = 1:numel(groundTruth),
        % compute the correspondence
        [match1,match2] = correspondPixels(bmap, double(groundTruth{i}.Boundaries), maxDist);
        % accumulate machine matches
        accP = accP | match1;
        % compute recall
        sumR(t) = sumR(t) + sum(groundTruth{i}.Boundaries(:));
        cntR(t) = cntR(t) + sum(match2(:)>0);
    end
    
    % compute precision
    sumP(t) = sumP(t) + sum(bmap(:));
    cntP(t) = cntP(t) + sum(accP(:));

end

% output
fid = fopen(prFile,'w');
if fid==-1,
    error('Could not open file %s for writing.', prFile);
end
fprintf(fid,'%10g %10g %10g %10g %10g\n',[thresh cntR sumR cntP sumP]');
fclose(fid);

