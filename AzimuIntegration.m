% =========================================================
% Author: Oliver Lin, University of Illnois Urbana-Champaign
% Last update: 2025-12-03
% Description: 
%   MATLAB script to perform azimuthal integration on 4D-STEM 
%   mappings on lattice shearing and rotation for all the grains.
% =========================================================

% === Input data ===
G5_shear_prime_masked_total = G5_shear_masked_total*0.57;
dataSets = {Diff_total, G5_shear_prime_masked_total};
dataNames = {'Rotation (°)', 'Shear_p (°)'};
clim = [-1 1];

% --- Parameters you can change later ---
angle_step_deg = 4;

% --- Geometry: center and endpoints in (x,y) formats---
% %#0430P5
center_input = [104, 107];  
endpoints = [127 17; 201 102; 140 199; 26 167; 21 59]; 
% %#0416P2
% center_input = [45, 45]; 
% endpoints = [33 9; 76 25; 76 67; 33 80; 6 44]; 
%#0416P1
% center_input = [45, 47]; 
% endpoints = [8 39; 44 11; 77 33; 68 71; 28 75]; 
%#0508P2
% center_input = [56, 59]; 
% endpoints = [63 11;105 48;78 103;17 96;10 39]; 
%#0508P5
% center_input = [56, 47]; 
% endpoints = [38 3;95 20;96 74;45 89;7 46]; 
%#0430P8
% center_input = [80, 80]; 
% endpoints = [98 14;146 80;100 144;24 120;24 40]; 
%#0319P3
% center_input = [113, 99]; 
% endpoints = [60 13;179 22;208 135;105 196;9 119]; 
% %#0430P6
% center_input = [77, 78]; 
% endpoints = [57 14;137 40;136 118;61 143;11 71]; 

%#0126P2
% center_input = [61, 61];
% endpoints = [28 25;87 23;111 73;63 109;15 77];
%#0126P1
% center_input = [59 60];
% endpoints = [42 15;103 34;102 89;43 107; 7 64];
%#0321P1
% center_input = [61, 58];
% endpoints = [21 23;86 13;113 62;69 109;11 81];
%#0321P2
% center_input = [59, 62];
% endpoints = [66 11;114 53;85 104;22 98;8 40];
%#0321P2
% center_input = [59, 62];
% endpoints = [66 11;114 53;85 104;22 98;8 40];
%#0430P7
% center_input = [87, 87]; 
% endpoints = [80 10;157 53;139 144;47 157;12 77]; 
% #0128P3
%center_input = [95, 97]; 
% endpoints = [83 19;172 65;155 154;10 87;83 19]; 
%#0319P5
% center_input = [116, 112]; 
% endpoints = [79 24;199 51;204 165;88 208;13 116]; 
%#0319P6
% center_input = [125, 114]; 
% endpoints = [85 10;208 48;212 173;98 215;21 117]; 

%#0126P4
% center_input = [65, 64]; 
% endpoints = [42 19;100 29;109 87;56 114;17 72]; 
%#0128P2
% center_input = [88,86]; 
% endpoints = [66 23;144 43;150 126;76 155;15 90]; 
%#0128P4
% center_input = [82, 80]; 
% endpoints = [57 17;138 41;142 121;63 145;11 82];
%#0128P5
% center_input = [80, 83]; 
% endpoints = [102 20;149 88;100 148;19 121;24 39];
%#0218P3
% center_input = [94, 93]; 
% endpoints = [89 18;169 63;146 152;54 159;15 79];
%#0128P5
% center_input = [99, 100]; 
% endpoints = [47 31;154 30;182 128;100 186;19 132];

% --- Radius ---
image_size = size(dataSets{1}, 1);
max_radius = floor(image_size / 2);
r_inner = 0.20 * max_radius;
r_outer = 1.00 * max_radius;

% --- Meshgrid & polar coordinates ---
[X, Y] = meshgrid(1:image_size, 1:image_size);
R = sqrt((X - center_input(1)).^2 + (Y - center_input(2)).^2);
A = atan2(Y - center_input(2), X - center_input(1));  % -pi to pi

% --- Sort endpoints counter-clockwise ---
vecs = endpoints - center_input;
endpoint_angles = atan2(vecs(:,2), vecs(:,1));  % -pi to pi
[sorted_angles, sort_idx] = sort(mod(endpoint_angles, 2*pi));  % [0, 2π)
angles_closed = [sorted_angles; sorted_angles(1) + 2*pi];
endpoints_sorted = endpoints(sort_idx, :);

% === Loop through datasets ===
for k = 1:length(dataSets)
    data = dataSets{k};
    name = dataNames{k};

    all_angles_deg = [];
    all_means = [];
    all_stds = [];

    % === Create tiled layout ===
    figure('Name', ['Wedge + Azimuthal Plot - ', name],'Position',[475,361,1000,500]);
    t = tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

    % === First tile: Image overlay of wedges ===
    nexttile;
    imagesc(data, clim);
    axis equal off;
    colormap parula;
    cb = colorbar;
    
    % Add title to the colorbar
    cb.FontSize = 12;
    cb.Label.String = [name];
    cb.Label.FontSize = 14;             % Optional: match your axis font size
    cb.Label.FontWeight = 'normal';     % Options: 'bold', 'normal', etc.
    cb.Label.Rotation = 90;             % 90 for vertical (default), 0 for horizontal
    cb.Label.HorizontalAlignment = 'center';

    title(['Wedge Overlay - ', name], 'Interpreter','none');
    hold on;
    plot(center_input(1), center_input(2), 'ro', 'MarkerSize', 6, 'LineWidth', 1.5);

    % === Wedge integration & overlay drawing ===
    for i = 1:5
        angle_start = angles_closed(i);
        angle_end = angles_closed(i+1);
        if angle_end < angle_start
            angle_end = angle_end + 2*pi;
        end

        % Subdivide wedge
        sub_angles = angle_start : deg2rad(angle_step_deg) : angle_end;
        mid_angles = sub_angles(1:end-1) + diff(sub_angles)/2;

        for j = 1:length(mid_angles)
            theta = mid_angles(j);
            wedge_half = deg2rad(angle_step_deg / 2);
            theta_mod = mod(theta, 2*pi);
            t1 = mod(theta_mod - wedge_half, 2*pi);
            t2 = mod(theta_mod + wedge_half, 2*pi);
            A_mod = mod(A, 2*pi);

            if t1 < t2
                angle_mask = (A_mod >= t1) & (A_mod <= t2);
            else
                angle_mask = (A_mod >= t1) | (A_mod <= t2);
            end
            mask = (R >= r_inner) & (R <= r_outer) & angle_mask;

            % Draw wedge edges
            x1 = center_input(1) + [r_inner, r_outer] * cos(t1);
            y1 = center_input(2) + [r_inner, r_outer] * sin(t1);
            x2 = center_input(1) + [r_inner, r_outer] * cos(t2);
            y2 = center_input(2) + [r_inner, r_outer] * sin(t2);
            plot(x1, y1, 'r-', 'LineWidth', 0.3);
            plot(x2, y2, 'r-', 'LineWidth', 0.3);

            % Integration
            values = data(mask);
            all_angles_deg(end+1) = mod(rad2deg(theta), 360);
            all_means(end+1) = mean(values, 'omitnan');
            all_stds(end+1) = std(values, 'omitnan');
        end

        % Draw outer arc
        arc_theta = linspace(angle_start, angle_end, 40);
        arc_x = center_input(1) + r_outer * cos(arc_theta);
        arc_y = center_input(2) + r_outer * sin(arc_theta);
        plot(arc_x, arc_y, 'r-', 'LineWidth', 0.6);
    end

    % === Second tile: Azimuthal plot ===
    nexttile;
    [sorted_angles_deg, idx] = sort(all_angles_deg);
    sorted_means = all_means(idx);
    sorted_stds = all_stds(idx);

    fill([sorted_angles_deg, fliplr(sorted_angles_deg)], ...
         [sorted_means + sorted_stds, fliplr(sorted_means - sorted_stds)], ...
         [0.85 0.85 0.85], 'EdgeColor', 'none');
    hold on;
    plot(sorted_angles_deg, sorted_means, 'k-', 'LineWidth', 2);
    xlabel('Azimuthal Angle (°)', 'FontSize', 14);
    ylabel(['Mean Intensity - ', name], 'FontSize', 14);
    title(['Azimuthal Integration - ', name], 'Interpreter','none');
    xlim([0 360]);
    xticks(0:30:360);
    ylim([-1 1]);
    grid on;
    legend({'±1σ', 'Mean'}, 'FontSize', 10, 'Location', 'best');
end
%% Before executing this part, manually pick the peaks on the azimuthal graph using data label (total 10 peaks)
%% This will report the summed value of the plot (either shear or rotation)
dcm = datacursormode(gcf);
set(dcm, 'DisplayStyle', 'datatip', 'SnapToDataVertex', 'on', 'Enable', 'on');

disp('📌 Use data cursor to click points. Then run:');
disp('    c_info = getCursorInfo(dcm);');
disp('    x_vals = arrayfun(@(c) c.Position(1), c_info);');
disp('    y_vals = arrayfun(@(c) c.Position(2), c_info);');
disp('    slopes = diff(y_vals) ./ diff(x_vals);');

% Example execution after licking:
c_info = getCursorInfo(datacursormode(gcf));             % get datatip info
x_vals = arrayfun(@(c) c.Position(1), c_info);            % extract x-values
y_vals = arrayfun(@(c) c.Position(2), c_info);            % extract y-valuesx
sum_abs_y = sum(abs(y_vals));                             % compute sum of absolute values
fprintf('Sum of absolute intensities: %.4f\n', sum_abs_y);
