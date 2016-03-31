% compute globalPb from mPb, sPb, and cues
function [gPb_orient gPb_thin] = gPb_from_cues(bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, mPb, sPb)

weights = [0  0  0.0039  0.0050  0.0058  0.0069  0.0040  0.0044  0.0049  0.0024  0.0027  0.0170  0.0074];

% get size of finest scale
[sx sy sz] = size(bg1);

gPb_orient = zeros(size(tg1));
for o = 1 : size(gPb_orient, 3),
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

    sc = weights(13)*imresize(sPb(:, :, o),[sx sy],'bilinear');

    gPb_orient(:, :, o) = l1 + a1 + b1 + t1 + l2 + a2 + b2 + t2 + l3 + a3 + b3 + t3 + sc;
end

%% outputs
gPb = max(gPb_orient, [], 3);

gPb_thin = gPb .* (mPb>0.05);
gPb_thin = gPb_thin .* bwmorph(gPb_thin, 'skel', inf);
