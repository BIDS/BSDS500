function [ bestF, bestP, bestR, bestT, F_max, P_max, R_max, Area_PR] = collect_eval_bdry(pbDir)
% function [ bestF, bestP, bestR, bestT, F_max, P_max, R_max, Area_PR ] = collect_eval_bdry(pbDir)
%
% calculate P, R and F-measure from individual evaluation files
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>


fname = fullfile(pbDir, 'eval_bdry.txt');
if (length(dir(fname))==1),
  tmp = dlmread(fname); 
  bestT = tmp(1);
  bestR = tmp(2);
  bestP = tmp(3);
  bestF = tmp(4);
  R_max = tmp(5);
  P_max = tmp(6);
  F_max = tmp(7);
  Area_PR = tmp(8);
else

    S = dir(fullfile(pbDir,'*_ev1.txt'));

    % deduce nthresh from .pr files
    filename = fullfile(pbDir,S(1).name);
    AA = dlmread(filename); % thresh cntR sumR cntP sumP

    thresh = AA(:,1);

    nthresh = numel(thresh);
    cntR_total = zeros(nthresh,1);
    sumR_total = zeros(nthresh,1);
    cntP_total = zeros(nthresh,1);
    sumP_total = zeros(nthresh,1);
    cntR_max = 0;
    sumR_max = 0;
    cntP_max = 0;
    sumP_max = 0;
    scores = zeros(length(S),5);

    for i = 1:length(S),

        iid = S(i).name(1:end-8);
        fprintf(2,'Processing image %s (%d/%d)...\n',iid,i,length(S));

        filename = fullfile(pbDir,S(i).name);
        AA  = dlmread(filename);
        cntR = AA(:, 2);
        sumR = AA(:, 3);
        cntP = AA(:, 4);
        sumP = AA(:, 5);

        R = cntR ./ (sumR + (sumR==0));
        P = cntP ./ (sumP + (sumP==0));
        F = fmeasure(R,P);

        [bestT,bestR,bestP,bestF] = maxF(thresh,R,P);
        scores(i,:) = [i bestT bestR bestP bestF];

        cntR_total = cntR_total + cntR;
        sumR_total = sumR_total + sumR;
        cntP_total = cntP_total + cntP;
        sumP_total = sumP_total + sumP;

        ff=find(F==max(F));
        cntR_max = cntR_max + cntR(ff(1));
        sumR_max = sumR_max + sumR(ff(1));
        cntP_max = cntP_max + cntP(ff(1));
        sumP_max = sumP_max + sumP(ff(1));

    end

    R = cntR_total ./ (sumR_total + (sumR_total==0));
    P = cntP_total ./ (sumP_total + (sumP_total==0));
    F = fmeasure(R,P);
    [bestT,bestR,bestP,bestF] = maxF(thresh,R,P);

    fname = fullfile(pbDir,'eval_bdry_img.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10d %10g %10g %10g %10g\n',scores');
    fclose(fid);

    fname = fullfile(pbDir,'eval_bdry_thr.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g\n',[thresh R P F]');
    fclose(fid);

    R_max = cntR_max ./ (sumR_max + (sumR_max==0));
    P_max = cntP_max ./ (sumP_max + (sumP_max==0));
    F_max = fmeasure(R_max,P_max);

    [Ru, indR] = unique(R);
    Pu = P(indR);
    Ri = 0 : 0.01 : 1;
    if numel(Ru)>1,
        P_int1 = interp1(Ru, Pu, Ri);
        P_int1(isnan(P_int1)) = 0;
        Area_PR = sum(P_int1)*0.01;

    else
        Area_PR = 0;
    end
    
    fname = fullfile(pbDir,'eval_bdry.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g %10g %10g %10g %10g\n',bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR);
    fclose(fid);

    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute f-measure fromm recall and precision
function [f] = fmeasure(r,p)
f = 2*p.*r./(p+r+((p+r)==0));

% interpolate to find best F and coordinates thereof
function [bestT,bestR,bestP,bestF] = maxF(thresh,R,P)
bestT = thresh(1);
bestR = R(1);
bestP = P(1);
bestF = fmeasure(R(1),P(1));
for i = 2:numel(thresh),
  for d = linspace(0,1),
    t = thresh(i)*d + thresh(i-1)*(1-d);
    r = R(i)*d + R(i-1)*(1-d);
    p = P(i)*d + P(i-1)*(1-d);
    f = fmeasure(r,p);
    if f > bestF,
      bestT = t;
      bestR = r;
      bestP = p;
      bestF = f;
    end
  end
end

