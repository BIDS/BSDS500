function [bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, textons] = det_mPb(im)
% compute image gradients. Implementation by Michael Maire.

% compute pb parts
[ ...
    textons, ...
    bg_r3, bg_r5,  bg_r10,  cga_r5, cga_r10, cga_r20, cgb_r5, cgb_r10, cgb_r20, tg_r5,  tg_r10,  tg_r20...
    ] = mex_pb_parts_final_selected(im(:,:,1),im(:,:,2),im(:,:,3));

[sx sy sz] = size(im);
temp = zeros([sx sy 8]);

for r = [3 5 10]
    for ori = 1:8
        eval(['temp(:,:,ori) = bg_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['bg_r' num2str(r) ' = temp;']);
end
bg1 = bg_r3; bg2 = bg_r5;  bg3 = bg_r10; 

for r = [5 10 20]
    for ori = 1:8
        eval(['temp(:,:,ori) = cga_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['cga_r' num2str(r) ' = temp;']);
end
cga1 = cga_r5; cga2 = cga_r10;  cga3 = cga_r20; 

for r = [5 10 20]
    for ori = 1:8
        eval(['temp(:,:,ori) = cgb_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['cgb_r' num2str(r) ' = temp;']);
end
cgb1 = cgb_r5; cgb2 = cgb_r10;  cgb3 = cgb_r20; 

for r = [5 10 20]
    for ori = 1:8
        eval(['temp(:,:,ori) = tg_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['tg_r' num2str(r) ' = temp;']);
end
tg1 = tg_r5; tg2 = tg_r10;  tg3 = tg_r20; 