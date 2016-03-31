% compute multiscale pb from cues
function [mPb_nmax, mPb_nmax_rsz] = mPb_from_cues(bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, rsz);

weights = [0.0146    0.0145    0.0163    0.0210    0.0243    0.0287    0.0166    0.0185    0.0204    0.0101    0.0111    0.0141];

% get size of finest scale
[sx sy sz] = size(bg1);

% compute mPb at full scale
mPb_all = zeros(size(tg1));
for o = 1 : size(mPb_all, 3),
    l1 = weights(1)*imresize(bg1(:, :, o),[sx sy],'bilinear');
    l2 = weights(2)*imresize(bg2(:, :, o),[sx sy],'bilinear');
    l3 = weights(3)*imresize(bg3(:, :, o),[sx sy],'bilinear');

    a1 = weights(4)*imresize(cga1(:, :, o),[sx sy],'bilinear');
    a2 = weights(5)*imresize(cga2(:, :, o),[sx sy],'bilinear');
    a3 = weights(6)*imresize(cga3(:, :, o),[sx sy],'bilinear');

    b1 = weights(7)*imresize(cgb1(:, :, o),[sx sy],'bilinear');
    b2 = weights(8)*imresize(cgb2(:, :, o),[sx sy],'bilinear');
    b3 = weights(9)*imresize(cgb3(:, :, o),[sx sy],'bilinear');

    t1 = weights(10)*imresize(tg1(:, :, o),[sx sy],'bilinear');
    t2 = weights(11)*imresize(tg2(:, :, o),[sx sy],'bilinear');
    t3 = weights(12)*imresize(tg3(:, :, o),[sx sy],'bilinear');

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
        l1 = weights(1)*imresize(bg1(:, :, o),[sx sy],'bilinear');
        l2 = weights(2)*imresize(bg2(:, :, o),[sx sy],'bilinear');
        l3 = weights(3)*imresize(bg3(:, :, o),[sx sy],'bilinear');

        a1 = weights(4)*imresize(cga1(:, :, o),[sx sy],'bilinear');
        a2 = weights(5)*imresize(cga2(:, :, o),[sx sy],'bilinear');
        a3 = weights(6)*imresize(cga3(:, :, o),[sx sy],'bilinear');

        b1 = weights(7)*imresize(cgb1(:, :, o),[sx sy],'bilinear');
        b2 = weights(8)*imresize(cgb2(:, :, o),[sx sy],'bilinear');
        b3 = weights(9)*imresize(cgb3(:, :, o),[sx sy],'bilinear');

        t1 = weights(10)*imresize(tg1(:, :, o),[sx sy],'bilinear');
        t2 = weights(11)*imresize(tg2(:, :, o),[sx sy],'bilinear');
        t3 = weights(12)*imresize(tg3(:, :, o),[sx sy],'bilinear');

        mPb_all(:, :, o) = imresize(l1 + a1 + b1 + t1 + l2 + a2 + b2 + t2 + l3 + a3 + b3 + t3, rsz);

    end

    mPb_nmax_rsz = nonmax_channels(mPb_all);
    mPb_nmax_rsz = max(0, min(1, 1.2*mPb_nmax_rsz));
else
    mPb_nmax_rsz = mPb_nmax;
end

