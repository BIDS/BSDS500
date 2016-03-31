function [bg, cga, cgb, tg, textons] = det_mPb_lg(im)

% compute pb parts
[ textons, bg_r10, cga_r20, cgb_r20, tg_r20 ] = ...
   mex_pb_parts_lg(im(:,:,1),im(:,:,2),im(:,:,3));

[sx sy sz] = size(im);
temp = zeros([sx sy 8]);

for r = [10]
    for ori = 1:8
        eval(['temp(:,:,ori) = bg_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['bg_r' num2str(r) ' = temp;']);
end
bg = bg_r10;

for r = [20]
    for ori = 1:8
        eval(['temp(:,:,ori) = cga_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['cga_r' num2str(r) ' = temp;']);
end
cga = cga_r20;

for r = [20]
    for ori = 1:8
        eval(['temp(:,:,ori) = cgb_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['cgb_r' num2str(r) ' = temp;']);
end
cgb = cgb_r20;

for r = [20]
    for ori = 1:8
        eval(['temp(:,:,ori) = tg_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['tg_r' num2str(r) ' = temp;']);
end
tg = tg_r20;
