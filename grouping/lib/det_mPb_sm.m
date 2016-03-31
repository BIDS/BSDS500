function [bg, cga, cgb, tg, textons] = det_mPb_sm(im)

% compute pb parts
[ textons, bg_r3, cga_r5, cgb_r5, tg_r5 ] = ...
   mex_pb_parts_sm(im(:,:,1),im(:,:,2),im(:,:,3));

[sx sy sz] = size(im);
temp = zeros([sx sy 8]);

for r = [3]
    for ori = 1:8
        eval(['temp(:,:,ori) = bg_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['bg_r' num2str(r) ' = temp;']);
end
bg = bg_r3;

for r = [5]
    for ori = 1:8
        eval(['temp(:,:,ori) = cga_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['cga_r' num2str(r) ' = temp;']);
end
cga = cga_r5;

for r = [5]
    for ori = 1:8
        eval(['temp(:,:,ori) = cgb_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['cgb_r' num2str(r) ' = temp;']);
end
cgb = cgb_r5;

for r = [5]
    for ori = 1:8
        eval(['temp(:,:,ori) = tg_r' num2str(r) '{' num2str(ori) '};']);
    end
    eval(['tg_r' num2str(r) ' = temp;']);
end
tg = tg_r5;
