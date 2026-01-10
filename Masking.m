% =========================================================
% Author: Oliver Lin, University of Illnois Urbana-Champaign
% Last update: 2025-12-03
% Description: 
%   MATLAB script to load virtual grain images, binarize, 
%   and combine masks for particle analysis.
%   User can define grain IDs and threshold values.
% =========================================================

% ---------------------------------------------------------
% USER INPUT
% Define the grain IDs you want to load.
% Include all the virtual images of grains in .jpg format in the folder
% Give an ID to each from (e.g. a 4D-STEM slice number) and put into
% grainIDs.
% Name the virtual image of the entire particle "combined.jpg"
% ---------------------------------------------------------
grainIDs = [3733, 6311, 15793, 30000, 36488];   % example user-defined list

% Preallocate a cell array to hold masks
binaryMasks = cell(length(grainIDs),1);
grain_binary_thres = 0.15;
contour_binary_thres = 0.65;

%% ---------------------------------------------------------
% LOAD & BINARIZE EACH GRAIN MASK. 
% ---------------------------------------------------------
figure;
for i = 1:length(grainIDs)
    
    % Construct the filename based on the grain ID
    fname = sprintf('%d.jpg', grainIDs(i));
    
    % Read the image
    img = imread(fname);

    % Convert to binary mask (adjust threshold as needed)
    binarized = im2bw(img, grain_binary_thres);

    % Save to cell array
    binaryMasks{i} = double(binarized);

    % Display each original + binary image for inspection
    subplot(length(grainIDs), 2, (i-1)*2 + 1);
    imagesc(img); colormap gray; axis image off;
    title(sprintf('Grain %d – Original', grainIDs(i)));

    subplot(length(grainIDs), 2, (i-1)*2 + 2);
    imagesc(binarized); colormap gray; axis image off;
    title(sprintf('Grain %d – Binarized', grainIDs(i)));
end

% ---------------------------------------------------------
% COMBINE ALL BINARY MASKS INTO ONE
% ---------------------------------------------------------
Masking_Total = zeros(size(binaryMasks{1}));

for i = 1:length(binaryMasks)
    Masking_Total = Masking_Total + binaryMasks{i};
end

% Show the combined mask
figure;
imagesc(Masking_Total); axis image off;
title('Combined Mask of All Grains');

%% ---------------------------------------------------------
% LOAD & BINARIZE PARTICLE CONTOUR. 
% ---------------------------------------------------------
Particle = imread("combined.jpg");

% Create threshold-dependent variable name
%    Example: contour_binary_thres = 0.65 → Particle_Binary_65
varName = sprintf('ParticleBinary%d', round(100 * contour_binary_thres));
Particle_Binary_temp = im2bw(Particle, contour_binary_thres);
Particle_Binary_temp = ~Particle_Binary_temp;
Particle_Binary_final = double(Particle_Binary_temp);
assignin('base', varName, Particle_Binary_final);

figure;
subplot(1, 2, 1);
imagesc(Particle);
colormap gray
axis image off;
title('Original Image');

subplot(1, 2, 2);
imagesc(Particle_Binary_temp);
axis image off;
title(sprintf('%s (Threshold = %.2f)', varName, contour_binary_thres));

%% ---------------------------------------------------------
% USER INPUT
% Include the coordinates of particle vertices (v1, v2) and center (c) as
% [v1, c, v2] for all five grains. Have the X-coordinates in x1-5 and
% Y-coordinates in y1-5
% Each grain is manually modified
% ---------------------------------------------------------
imgSize = size(Particle,1);
j = 1;

xj = eval(sprintf('x%d', j));
yj = eval(sprintf('y%d', j));

bw_temp = poly2mask(xj, yj, imgSize, imgSize);
bw_temp = ~bw_temp;
bw_temp = double(bw_temp);
bw_temp = bw_temp + 1;
bwVar = sprintf('bw%d', grainIDs(j));

assignin('base', bwVar, bw_temp);
ToManual=bw_temp.*Particle_Binary_final;
ToManual(ToManual==1)=128;

figure;
imagesc(ToManual);
axis image off;
title(bwVar);

openvar('ToManual');
% Change all the 2's spatially between 0 and 128 into 128 in the matrix
% shown.
% iterate through j = 1-5
% When finished, change the variable name of finishd mask to
% "Mask_grainID," which will be imported to the Jupyter notebook.

