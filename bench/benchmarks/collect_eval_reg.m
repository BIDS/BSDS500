function collect_eval_reg(ucmDir)
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>

fname = fullfile(ucmDir, 'eval_cover.txt');
if (length(dir(fname))~=1),
    
    S = dir(fullfile(ucmDir,'*_ev2.txt'));
    
    % deduce nthresh from files
    AA = dlmread(fullfile(ucmDir,S(1).name));
    nthresh = size(AA,1);
    
    cntR_total = zeros(nthresh,1);
    sumR_total = zeros(nthresh,1);
    cntP_total = zeros(nthresh,1);
    sumP_total = zeros(nthresh,1);
    cntR_best = 0;
    sumR_best = 0;
    cntP_best = 0;
    sumP_best = 0;
    globalRI = zeros(nthresh,1);
    globalVOI = zeros(nthresh,1);
    RI_best = 0;
    VOI_best = 0;
    
    cntR_best_total = 0;
    
    scores = zeros(numel(S),4);
    
    for i = 1:numel(S),
        
        iid = S(i).name(1:end-8);
        fprintf(2,'Processing image %s (%d/%d)...\n',iid,i,length(S));
        
        evFile1 = fullfile(ucmDir,S(i).name);
        tmp  = dlmread(evFile1);
        thresh = tmp(:, 1);
        cntR = tmp(:, 2);
        sumR = tmp(:, 3);
        cntP = tmp(:, 4);
        sumP = tmp(:, 5);
        
        R = cntR ./ (sumR + (sumR==0));
        P = cntP ./ (sumP + (sumP==0));
        
        [bestR ind] = max(R);
        bestT = thresh(ind(1));
        bestP = P(ind(1));
        scores(i,:) = [i bestT bestR bestP ];
        
        cntR_total = cntR_total + cntR;
        sumR_total = sumR_total + sumR;
        cntP_total = cntP_total + cntP;
        sumP_total = sumP_total + sumP;
        
        ff=find(R==max(R));
        cntR_best = cntR_best + cntR(ff(end));
        sumR_best = sumR_best + sumR(ff(end));
        cntP_best = cntP_best + cntP(ff(end));
        sumP_best = sumP_best + sumP(ff(end));
        
        evFile2 = fullfile(ucmDir,[S(i).name(1:end-5) '3.txt']);
        tmp  = dlmread(evFile2);
        cntR_best_total = cntR_best_total + tmp(1);
        
        evFile3 = fullfile(ucmDir,[S(i).name(1:end-5) '4.txt']);
        tmp  = dlmread(evFile3);
        globalRI = globalRI + tmp(:,2);
        globalVOI = globalVOI + tmp(:,3);
        
        ff = find( tmp(:,2)==max(tmp(:,2)) );
        RI_best = RI_best + tmp(ff(end),2);
        ff = find( tmp(:,3)==min(tmp(:,3)) );
        VOI_best = VOI_best + tmp(ff(end),3);
        
    end
    
    R = cntR_total ./ (sumR_total + (sumR_total==0));
    
    [bestR ind] = max(R);
    bestT = thresh(ind(1));
    
    fname = fullfile(ucmDir,'eval_cover_img.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10d %10g %10g %10g\n',scores');
    fclose(fid);
    
    fname = fullfile(ucmDir,'eval_cover_th.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g\n',[thresh R]');
    fclose(fid);
    
    R_best = cntR_best ./ (sumR_best + (sumR_best==0));
    
    R_best_total = cntR_best_total / sumR_total(1) ;
    
    fname = fullfile(ucmDir,'eval_cover.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g\n',bestT, bestR, R_best, R_best_total);
    fclose(fid);
    
    globalRI = globalRI / numel(S);
    globalVOI = globalVOI / numel(S);
    RI_best = RI_best / numel(S);
    VOI_best = VOI_best / numel(S);
    [bgRI igRI]=max(globalRI);
    [bgVOI igVOI]=min(globalVOI);
    
    fname = fullfile(ucmDir,'eval_RI_VOI_thr.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g\n',[thresh globalRI globalVOI]');
    fclose(fid);

    fname = fullfile(ucmDir,'eval_RI_VOI.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g %10g %10g\n',thresh(igRI), bgRI, RI_best, thresh(igVOI),  bgVOI, VOI_best);
    fclose(fid);
    
    
end

