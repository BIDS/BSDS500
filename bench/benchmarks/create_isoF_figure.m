%clear all;close all;clc;

h=figure;
title('Boundary Benchmark on BSDS');
hold on;

plot(0.700762,0.897659,'go','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize',10);
%% isoF lines
[p,r] = meshgrid(0.01:0.01:1,0.01:0.01:1);
F=2*p.*r./(p+r);
[C,h] = contour(p,r,F);

% colormap green
map=zeros(256,3); map(:,1)=0; map(:,2)=1; map(:,3)=0; colormap(map);

box on;
grid on;
set(gca,'XTick',0:0.1:1);
set(gca,'YTick',0:0.1:1);
set(gca,'XGrid','on');
set(gca,'YGrid','on');
xlabel('Recall');
ylabel('Precision');
title('');
axis square;
axis([0 1 0 1]);
