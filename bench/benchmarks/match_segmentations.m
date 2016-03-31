function [matches ] = match_segmentations(seg, groundTruth)
% match a test segmentation to a set of ground-truth segmentations with the SEGMENTATION COVERING metric.
% based on PASCAL evaluation code:
% http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2010/index.html#devkit

total_gt = 0;
for s = 1 : numel(groundTruth)
    total_gt = total_gt + max(groundTruth{s}.Segmentation(:));
end

cnt = 0;
matches = zeros(total_gt, max(seg(:)));
for s = 1 : numel(groundTruth)
    gt = groundTruth{s}.Segmentation;

    num1 = max(gt(:)) + 1; 
    num2 = max(seg(:)) + 1;
    confcounts = zeros(num1, num2);

    % joint histogram
    sumim = 1 + gt + seg*num1;

    hs = histc(sumim(:), 1:num1*num2);
    confcounts(:) = confcounts(:) + hs(:);

    accuracies = zeros(num1-1, num2-1);
    for j = 1:num1
        for i = 1:num2
            gtj = sum(confcounts(j, :));
            resj = sum(confcounts(:, i));
            gtjresj = confcounts(j, i);
            accuracies(j, i) = gtjresj / (gtj + resj - gtjresj);
        end
    end
    matches(cnt+1:cnt+max(gt(:)), :) = accuracies(2:end, 2:end);
    cnt = cnt + max(gt(:));
end

matches = matches';




