function [ucm2] = im2ucm(imgFile, outFile)

gPb_orient = globalPb(imgFile, outFile);
ucm2 = contours2ucm(gPb_orient, 'doubleSize');
save(outFile,'ucm2');
