addpath('utils/')
nameList = dir('ParticleImages/*.tif');
for i = 1 :length(nameList)
   I = double(imread([nameList(i).folder,'/',nameList(i).name]));
   I = (I-min(I(:)))/(max(I(:))-min(I(:)));
   I_b = imgaussfilt(I,10);
   I_b = imbinarize(I_b);
   [B,L] = bwboundaries(I_b);
   stats = regionprops(L,'Centroid','Area','Circularity');
   [~,ID] = max([stats.Area]);
   B = B{ID};
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
   cen = stats.Centroid;
   B_cen = B-[cen(2),cen(1)];
   profile_ = signature_no_rotation(B,cen);
   [~,maxma] =  findpeaks(profile_,'MinPeakDistance',60);
   B_angles = mod(atan2d(B_cen(:,1),B_cen(:,2)),360);
    
   figure(1);clf
   set(gcf,'position',[200 200 512 512])
   set(gca,'position',[0 0 1 1])
   imagesc(transpose(I))
   colormap('gray')
   hold on
   [edge,trunc,A] = edge_truncation_finder(20/2,B,B_angles,maxma,cen,1);%%increase the first argument to shorten green dot spans
   angles = [maxma(2)-maxma(1),maxma(3)-maxma(2),maxma(4)-maxma(3),maxma(5)-maxma(4),maxma(1)+360-maxma(5),];
   %%%%% %%%%% %%%%%console output%%%%% %%%%% %%%%%
   disp('======================================')
   disp(['Image: ', num2str(i)])
   disp(['Edge (cyan segs, L2,L3,L4,L5,L1) length: ', num2str(edge), ' px'])
   disp(['Truncation (red segs, V1,V2,V3,V4,L5): ', num2str(trunc), ' px'])
   disp(['Angle (white rays, L2,L3,L4,L5,L1): ', num2str(angles), ' degree'])
   disp(['Angle (cyan cross, V1,V2,V3,V4,L5): ', num2str(A), ' degree'])
   disp(['Circularity: ', num2str(stats(ID).Circularity)])
   disp('======================================')
   saveas(gcf,['plotted images/',nameList(i).name])
end

function [edge,trunc,A] = edge_truncation_finder(margin,B,B_angles,maxma,cen,plot_mode)
    L1UB = mod(maxma(1)+180,360)-margin;
    L1LB = mod(maxma(5)+180,360)+margin;
    
    L1 = B(mod(B_angles+180,360)>= L1LB&mod(B_angles+180,360)<L1UB,:);
    L2 = B(B_angles>=maxma(1)+margin&B_angles<maxma(2)-margin,:);
    L3 = B(B_angles>=maxma(2)+margin&B_angles<maxma(3)-margin,:);
    L4 = B(B_angles>=maxma(3)+margin&B_angles<maxma(4)-margin,:);
    L5 = B(B_angles>=maxma(4)+margin&B_angles<maxma(5)-margin,:);
    a1 = orthogonal_regression(L1);
    a2 = orthogonal_regression(L2);
    a3 = orthogonal_regression(L3);
    a4 = orthogonal_regression(L4);
    a5 = orthogonal_regression(L5);
    t1 = intersection(a1,a2);A1 = vector_angle(a1,a2);
    t2 = intersection(a2,a3);A2 = vector_angle(a2,a3);
    t3 = intersection(a3,a4);A3 = vector_angle(a3,a4);
    t4 = intersection(a4,a5);A4 = vector_angle(a4,a5);
    t5 = intersection(a5,a1);A5 = vector_angle(a5,a1);
    [tt1x,tt1y] =  polyxpoly([t1(1);cen(2)],[t1(2);cen(1)],B(:,1),B(:,2));tt1 = [tt1x,tt1y];
    [tt2x,tt2y] =  polyxpoly([t2(1);cen(2)],[t2(2);cen(1)],B(:,1),B(:,2));tt2 = [tt2x,tt2y];
    [tt3x,tt3y] =  polyxpoly([t3(1);cen(2)],[t3(2);cen(1)],B(:,1),B(:,2));tt3 = [tt3x,tt3y];
    [tt4x,tt4y] =  polyxpoly([t4(1);cen(2)],[t4(2);cen(1)],B(:,1),B(:,2));tt4 = [tt4x,tt4y];
    [tt5x,tt5y] =  polyxpoly([t5(1);cen(2)],[t5(2);cen(1)],B(:,1),B(:,2));tt5 = [tt5x,tt5y];
    if plot_mode
        plot(B(:,1),B(:,2),'white')
        scatter(L1(:,1),L1(:,2),'g')
        text(mean(L1(:,1)),mean(L1(:,2)),'L1','color','white')
        scatter(L2(:,1),L2(:,2),'g')
        text(mean(L2(:,1)),mean(L2(:,2)),'L2','color','white')
        scatter(L3(:,1),L3(:,2),'g')
        text(mean(L3(:,1)),mean(L3(:,2)),'L3','color','white')
        scatter(L4(:,1),L4(:,2),'g')
        text(mean(L4(:,1)),mean(L4(:,2)),'L4','color','white')
        scatter(L5(:,1),L5(:,2),'g')
        text(mean(L5(:,1)),mean(L5(:,2)),'L5','color','white')
    
        x_box = 1:1:2048;
        plot(x_box,x_box*a1(1)+a1(2),'cyan');
        plot(x_box,x_box*a2(1)+a2(2),'cyan');
        plot(x_box,x_box*a3(1)+a3(2),'cyan');
        plot(x_box,x_box*a4(1)+a4(2),'cyan');
        plot(x_box,x_box*a5(1)+a5(2),'cyan');
        plot([t1(1);cen(2)],[t1(2);cen(1)],'white')
        plot([t2(1);cen(2)],[t2(2);cen(1)],'white')
        plot([t3(1);cen(2)],[t3(2);cen(1)],'white')
        plot([t4(1);cen(2)],[t4(2);cen(1)],'white')
        plot([t5(1);cen(2)],[t5(2);cen(1)],'white')
        scatter(tt1x,tt1y,'r')
        text(tt1x+30,tt1y,'V1','color','white')
        scatter(tt2x,tt2y,'r')
        text(tt2x+30,tt2y,'V2','color','white')
        scatter(tt3x,tt3y,'r')
        text(tt3x+30,tt3y,'V3','color','white')
        scatter(tt4x,tt4y,'r')
        text(tt4x+30,tt4y,'V4','color','white')
        scatter(tt5x,tt5y,'r')
        text(tt5x+30,tt5y,'V5','color','white')
    
        plot([tt1x;t1(1)],[tt1y;t1(2)],'r')
        plot([tt2x;t2(1)],[tt2y;t2(2)],'r')
        plot([tt3x;t3(1)],[tt3y;t3(2)],'r')
        plot([tt4x;t4(1)],[tt4y;t4(2)],'r')
        plot([tt5x;t5(1)],[tt5y;t5(2)],'r')
    end
    edge = [norm(t1-t2),norm(t2-t3),norm(t3-t4),norm(t4-t5),norm(t5-t1)];
    trunc = [norm(tt1-t1),norm(tt2-t2),norm(tt3-t3),norm(tt4-t4),norm(tt5-t5)];
    A = [A1,A2,A3,A4,A5];
end

function theta = vector_angle(a, b)
    theta =atan2d(norm(cross([1;a(1);0],[1;b(1);0])), dot([1;a(1)],[1;b(1)]));
    theta = max([theta,180-theta]);
    theta = theta(1);
end