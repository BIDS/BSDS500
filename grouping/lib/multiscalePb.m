function [mPb_nmax, mPb_nmax_rsz, bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, textons] = multiscalePb(im, rsz)
%function [mPb_nmax, mPb_nmax_rsz, bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, textons] = multiscalePb(im, rsz)
%
% description:
% compute local contour cues of an image.
%
% gradients by Michael Maire <mmaire@eecs.berkeley.edu>
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
% December 2010
if nargin<2, rsz = 1.0; end


% default feature weights
if size(im,3) == 3,
    weights = [0.0146    0.0145    0.0163    0.0210    0.0243    0.0287    0.0166    0.0185    0.0204    0.0101    0.0111    0.0141];
else
    im(:,:,2)=im(:,:,1);im(:,:,3)=im(:,:,1);
    weights = [0.0245    0.0220    0.0233         0         0         0         0         0         0    0.0208    0.0210    0.0229];
end

% get gradients
tic;
[bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, textons] = det_mPb(im);
fprintf('Local cues: %g\n', toc);

% smooth cues
gtheta = [1.5708    1.1781    0.7854    0.3927   0    2.7489    2.3562    1.9635];
tic;
filters = make_filters([3 5 10 20], gtheta);
for o = 1 : size(tg1, 3),
    bg1(:,:,o) = fitparab(bg1(:,:,o),3,3/4,gtheta(o),filters{1,o});
    bg2(:,:,o) = fitparab(bg2(:,:,o),5,5/4,gtheta(o),filters{2,o});
    bg3(:,:,o) = fitparab(bg3(:,:,o),10,10/4,gtheta(o),filters{3,o});

    cga1(:,:,o) = fitparab(cga1(:,:,o),5,5/4,gtheta(o),filters{2,o});
    cga2(:,:,o) = fitparab(cga2(:,:,o),10,10/4,gtheta(o),filters{3,o});
    cga3(:,:,o) = fitparab(cga3(:,:,o),20,20/4,gtheta(o),filters{4,o});

    cgb1(:,:,o) = fitparab(cgb1(:,:,o),5,5/4,gtheta(o),filters{2,o});
    cgb2(:,:,o) = fitparab(cgb2(:,:,o),10,10/4,gtheta(o),filters{3,o});
    cgb3(:,:,o) = fitparab(cgb3(:,:,o),20,20/4,gtheta(o),filters{4,o});

    tg1(:,:,o) = fitparab(tg1(:,:,o),5,5/4,gtheta(o),filters{2,o});
    tg2(:,:,o) = fitparab(tg2(:,:,o),10,10/4,gtheta(o),filters{3,o});
    tg3(:,:,o) = fitparab(tg3(:,:,o),20,20/4,gtheta(o),filters{4,o});

end
fprintf('Cues smoothing: %g\n', toc);


% compute mPb at full scale
mPb_all = zeros(size(tg1));
for o = 1 : size(mPb_all, 3),
    l1 = weights(1)*bg1(:, :, o);
    l2 = weights(2)*bg2(:, :, o);
    l3 = weights(3)*bg3(:, :, o);

    a1 = weights(4)*cga1(:, :, o);
    a2 = weights(5)*cga2(:, :, o);
    a3 = weights(6)*cga3(:, :, o);

    b1 = weights(7)*cgb1(:, :, o);
    b2 = weights(8)*cgb2(:, :, o);
    b3 = weights(9)*cgb3(:, :, o);

    t1 = weights(10)*tg1(:, :, o);
    t2 = weights(11)*tg2(:, :, o);
    t3 = weights(12)*tg3(:, :, o);

    mPb_all(:, :, o) = l1 + a1 + b1 + t1 + l2 + a2 + b2 + t2 + l3 + a3 + b3 + t3;

end

% non-maximum suppression
mPb_nmax = nonmax_channels(mPb_all);
mPb_nmax = max(0, min(1, 1.2*mPb_nmax));


% compute mPb_nmax resized if necessary
if rsz < 1,
    mPb_all = imresize(tg1, rsz);
    mPb_all(:) = 0;

    for o = 1 : size(mPb_all, 3),
        l1 = weights(1)*bg1(:, :, o);
        l2 = weights(2)*bg2(:, :, o);
        l3 = weights(3)*bg3(:, :, o);

        a1 = weights(4)*cga1(:, :, o);
        a2 = weights(5)*cga2(:, :, o);
        a3 = weights(6)*cga3(:, :, o);

        b1 = weights(7)*cgb1(:, :, o);
        b2 = weights(8)*cgb2(:, :, o);
        b3 = weights(9)*cgb3(:, :, o);

        t1 = weights(10)*tg1(:, :, o);
        t2 = weights(11)*tg2(:, :, o);
        t3 = weights(12)*tg3(:, :, o);

        mPb_all(:, :, o) = imresize(l1 + a1 + b1 + t1 + l2 + a2 + b2 + t2 + l3 + a3 + b3 + t3, rsz);

    end

    mPb_nmax_rsz = nonmax_channels(mPb_all);
    mPb_nmax_rsz = max(0, min(1, 1.2*mPb_nmax_rsz));
else
    mPb_nmax_rsz = mPb_nmax;
end


%%
function filters = make_filters(radii, gtheta)

d = 2; 

filters = cell(numel(radii), numel(gtheta));
for r = 1:numel(radii),
    for t = 1:numel(gtheta),
        
        ra = radii(r);
        rb = ra / 4;
        theta = gtheta(t);
        
        ra = max(1.5, ra);
        rb = max(1.5, rb);
        ira2 = 1 / ra^2;
        irb2 = 1 / rb^2;
        wr = floor(max(ra, rb));
        wd = 2*wr+1;
        sint = sin(theta);
        cost = cos(theta);
        
        % 1. compute linear filters for coefficients
        % (a) compute inverse of least-squares problem matrix
        filt = zeros(wd,wd,d+1);
        xx = zeros(2*d+1,1);
        for u = -wr:wr,
            for v = -wr:wr,
                ai = -u*sint + v*cost; % distance along major axis
                bi = u*cost + v*sint; % distance along minor axis
                if ai*ai*ira2 + bi*bi*irb2 > 1, continue; end % outside support
                xx = xx + cumprod([1;ai+zeros(2*d,1)]);
            end
        end
        A = zeros(d+1,d+1);
        for i = 1:d+1,
            A(:,i) = xx(i:i+d);
        end
        
        % (b) solve least-squares problem for delta function at each pixel
        for u = -wr:wr,
            for v = -wr:wr,
                ai = -u*sint + v*cost; % distance along major axis
                bi = u*cost + v*sint; % distance along minor axis
                if (ai*ai*ira2 + bi*bi*irb2) > 1, continue; end % outside support
                yy = cumprod([1;ai+zeros(d,1)]);
                filt(v+wr+1,u+wr+1,:) = A\yy;
            end
        end
        
        filters{r,t}=filt;
    end
end

