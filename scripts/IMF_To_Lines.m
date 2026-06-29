%% MATLAB Code: Line Profile Extraction from 2D Data (Original, IMFs, Residual, Depth1, Depth2)
% Works with:
%   Original.mat          -> variable 'image'
%   Residual.mat          -> variable 'residual'
%   IMF_*.mat             -> variable 'imf'
%   dt_matrix_Depth_1.mat -> variable 'combined'
%   dt_matrix_Depth_2.mat -> variable 'combined'
% The user selects the folder, then defines a line interactively on the
% original data plot. The Y-axis is set to normal orientation (row 1 at bottom)
% so that the origin (0,0) is at the bottom-left corner.
% Results are saved in a new subfolder as .mat, .xlsx, .txt, .png, and coordinates.
% Additional plots for Depth_1 and Depth_2 are created in a second figure.

clear; clc; close all;

%% ==================== STEP 0: SELECT WORKING FOLDER ====================
fprintf('Please select the folder containing your .mat files...\n');
folderPath = uigetdir(pwd, 'Select folder with Original.mat, Residual.mat, IMF_*.mat, and Depth files');
if folderPath == 0
    error('No folder selected. Script aborted.');
end
fprintf('Working folder: %s\n', folderPath);
cd(folderPath);

%% ==================== STEP 1: LOAD ORIGINAL DATA ====================
fprintf('\n=== STEP 1: Loading original data ===\n');
if ~exist('Original.mat', 'file')
    error('Original.mat not found in selected folder.');
end
load('Original.mat', 'image');   % loads variable 'image'
original = image;
fprintf('Original data size: %d x %d\n', size(original,1), size(original,2));

%% ==================== STEP 2: LOAD RESIDUAL ====================
fprintf('\n=== STEP 2: Loading residual matrix ===\n');
if ~exist('Residual.mat', 'file')
    error('Residual.mat not found in selected folder.');
end
load('Residual.mat', 'residual'); % loads variable 'residual'
fprintf('Residual size: %d x %d\n', size(residual,1), size(residual,2));

%% ==================== STEP 3: LOAD IMFs (auto-detect) ====================
fprintf('\n=== STEP 3: Loading IMF files ===\n');
imfFiles = dir('IMF_*.mat');
if isempty(imfFiles)
    error('No IMF_*.mat files found.');
end

% Extract numbers from filenames and sort
numIMFs = length(imfFiles);
imfNumbers = zeros(numIMFs, 1);
for k = 1:numIMFs
    tokens = regexp(imfFiles(k).name, '\d+', 'match');
    if ~isempty(tokens)
        imfNumbers(k) = str2double(tokens{1});
    else
        imfNumbers(k) = k;
    end
end
[~, sortIdx] = sort(imfNumbers);
imfFiles = imfFiles(sortIdx);
imfNumbers = imfNumbers(sortIdx);

% Load each IMF
IMFs = cell(numIMFs, 1);
for k = 1:numIMFs
    filename = imfFiles(k).name;
    load(filename, 'imf');
    IMFs{k} = imf;
    fprintf('Loaded %s -> IMF #%d\n', filename, imfNumbers(k));
end
fprintf('Total IMFs loaded: %d\n', numIMFs);

%% ==================== STEP 4: LOAD DEPTH MATRICES (dt_matrix_Depth_1 and _2) ====================
fprintf('\n=== STEP 4: Loading depth matrices ===\n');
if ~exist('dt_matrix_Depth_1.mat', 'file')
    error('dt_matrix_Depth_1.mat not found.');
end
load('dt_matrix_Depth_1.mat', 'combined');   % variable 'combined'
depth1 = combined;
fprintf('Loaded dt_matrix_Depth_1.mat, size: %d x %d\n', size(depth1,1), size(depth1,2));

if ~exist('dt_matrix_Depth_2.mat', 'file')
    error('dt_matrix_Depth_2.mat not found.');
end
load('dt_matrix_Depth_2.mat', 'combined');
depth2 = combined;
fprintf('Loaded dt_matrix_Depth_2.mat, size: %d x %d\n', size(depth2,1), size(depth2,2));

%% ==================== VERIFY CONSISTENT SIZES ====================
refSize = size(original);
if any(size(residual) ~= refSize)
    error('Residual size does not match original.');
end
for k = 1:numIMFs
    if any(size(IMFs{k}) ~= refSize)
        error('IMF %d size does not match original.', imfNumbers(k));
    end
end
if any(size(depth1) ~= refSize)
    error('dt_matrix_Depth_1 size does not match original.');
end
if any(size(depth2) ~= refSize)
    error('dt_matrix_Depth_2 size does not match original.');
end
fprintf('All matrices have consistent size: %d x %d\n', refSize(1), refSize(2));

%% ==================== USER INPUT: SAMPLING STEP ====================
prompt = {'Enter sampling step along the line (in pixels):'};
dlgtitle = 'Sampling Step';
dims = [1 35];
definput = {'1'};
answer = inputdlg(prompt, dlgtitle, dims, definput);
if isempty(answer)
    stepSize = 1;
else
    stepSize = str2double(answer{1});
    if isnan(stepSize) || stepSize <= 0
        stepSize = 1;
    end
end
fprintf('Sampling step = %.2f pixels\n', stepSize);

%% ==================== INTERACTIVE LINE SELECTION ====================
% Plot original data with normal Y axis (origin at bottom-left)
figure('Name', 'Original Data - Select Line Endpoints');
imagesc(original);
colormap('jet');
colorbar;
axis image;
set(gca, 'YDir', 'normal');        % Reverse default: row 1 at bottom, origin at bottom-left
xlim([0, size(original,2)]);       % Start x-axis at 0
ylim([0, size(original,1)]);       % Start y-axis at 0
title('Click two points: start (green) and end (red) of profile line');
xlabel('Column index'); ylabel('Row index');

disp('Click two points on the plot (start and end of the line).');
[x_click, y_click] = ginput(2);
if length(x_click) < 2
    error('Two points were not selected.');
end

pt1 = [x_click(1), y_click(1)];
pt2 = [x_click(2), y_click(2)];

% Draw line on figure for confirmation
hold on;
plot([pt1(1), pt2(1)], [pt1(2), pt2(2)], 'r-', 'LineWidth', 2);
plot(pt1(1), pt1(2), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(pt2(1), pt2(2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
hold off;
drawnow;

%% ==================== SAMPLE POINTS ALONG THE LINE ====================
lineVec = pt2 - pt1;
lineLength = norm(lineVec);
numSamples = max(2, round(lineLength / stepSize) + 1);
t = linspace(0, 1, numSamples);
x_coords = pt1(1) + t * lineVec(1);
y_coords = pt1(2) + t * lineVec(2);

% Create interpolation grid (meshgrid expects X = columns, Y = rows)
[Xgrid, Ygrid] = meshgrid(1:size(original,2), 1:size(original,1));

% Interpolate original, residual, depth1, depth2
orig_profile = interp2(Xgrid, Ygrid, original, x_coords, y_coords, 'linear');
res_profile = interp2(Xgrid, Ygrid, residual, x_coords, y_coords, 'linear');
depth1_profile = interp2(Xgrid, Ygrid, depth1, x_coords, y_coords, 'linear');
depth2_profile = interp2(Xgrid, Ygrid, depth2, x_coords, y_coords, 'linear');

% Interpolate each IMF
imf_profiles = zeros(numIMFs, numSamples);
for k = 1:numIMFs
    imf_profiles(k, :) = interp2(Xgrid, Ygrid, IMFs{k}, x_coords, y_coords, 'linear');
end

% Package all data into a structure
profileData = struct();
profileData.line_start = pt1;
profileData.line_end = pt2;
profileData.sampling_step_pixels = stepSize;
profileData.num_samples = numSamples;
profileData.x_coords = x_coords;
profileData.y_coords = y_coords;
profileData.original = orig_profile;
profileData.residual = res_profile;
profileData.IMFs = imf_profiles;
profileData.IMF_numbers = imfNumbers;
profileData.depth1 = depth1_profile;
profileData.depth2 = depth2_profile;

%% ==================== CREATE OUTPUT FOLDER ====================
outputFolder = fullfile(folderPath, sprintf('LineProfiles_%s', datestr(now, 'yyyymmdd_HHMMSS')));
mkdir(outputFolder);
fprintf('\nResults will be saved in: %s\n', outputFolder);

%% ==================== PLOT 1: ORIGINAL, IMFs, RESIDUAL ====================
% Distance along the line (cumulative Euclidean distance)
dist = [0, cumsum(sqrt(diff(x_coords).^2 + diff(y_coords).^2))];

figure('Name', 'Line Profiles - Original, IMFs, Residual', 'Position', [100, 100, 1200, 800]);

% Subplot 1: Original data
subplot(3,1,1);
plot(dist, orig_profile, 'b-', 'LineWidth', 1.5);
title('Original Data Profile');
ylabel('Value'); grid on;

% Subplot 2: All IMFs (overlaid)
subplot(3,1,2);
hold on;
colors = jet(numIMFs);
for k = 1:numIMFs
    plot(dist, imf_profiles(k,:), 'Color', colors(k,:), 'LineWidth', 1);
end
hold off;
title(sprintf('IMF Profiles (%d components)', numIMFs));
ylabel('IMF Value');
legendCell = arrayfun(@(x) sprintf('IMF%d', x), imfNumbers, 'UniformOutput', false);
legend(legendCell, 'Location', 'eastoutside');
grid on;

% Subplot 3: Residual
subplot(3,1,3);
plot(dist, res_profile, 'r-', 'LineWidth', 1.5);
title('Residual Profile');
xlabel('Distance along line (pixels)'); ylabel('Value');
grid on;

% Save first figure
figPath1 = fullfile(outputFolder, 'profiles_plot_original_IMFs_residual.png');
saveas(gcf, figPath1);
fprintf('Plot 1 saved: %s\n', figPath1);

%% ==================== PLOT 2: DEPTH1 and DEPTH2 ====================
figure('Name', 'Line Profiles - Depth Matrices', 'Position', [150, 150, 1000, 600]);

% Plot both depth profiles in one figure with two subplots or overlaid? 
% Let's do two subplots for clarity.
subplot(2,1,1);
plot(dist, depth1_profile, 'g-', 'LineWidth', 1.5);
title('dt\_matrix\_Depth\_1 Profile');
ylabel('Value'); grid on;

subplot(2,1,2);
plot(dist, depth2_profile, 'm-', 'LineWidth', 1.5);
title('dt\_matrix\_Depth\_2 Profile');
xlabel('Distance along line (pixels)'); ylabel('Value');
grid on;

% Save second figure
figPath2 = fullfile(outputFolder, 'profiles_plot_depth1_depth2.png');
saveas(gcf, figPath2);
fprintf('Plot 2 saved: %s\n', figPath2);

% Optional: Overlay both depth profiles in a single plot
figure('Name', 'Depth Profiles Overlay', 'Position', [200, 200, 800, 500]);
plot(dist, depth1_profile, 'g-', 'LineWidth', 1.5); hold on;
plot(dist, depth2_profile, 'm-', 'LineWidth', 1.5);
legend('Depth 1', 'Depth 2');
title('Comparison of Depth Matrices along Line');
xlabel('Distance along line (pixels)'); ylabel('Value');
grid on;
figPath3 = fullfile(outputFolder, 'profiles_plot_depth_overlay.png');
saveas(gcf, figPath3);
fprintf('Overlay plot saved: %s\n', figPath3);

%% ==================== SAVE DATA IN MULTIPLE FORMATS ====================
% 1. Save as .mat file (contains all profiles)
matFile = fullfile(outputFolder, 'line_profiles.mat');
save(matFile, 'profileData');
fprintf('MAT file saved: %s\n', matFile);

% 2. Save as Excel (.xlsx) - includes original, IMFs, residual, depth1, depth2
T = table(dist(:), orig_profile(:), 'VariableNames', {'Distance_pixels', 'Original'});
for k = 1:numIMFs
    T = addvars(T, imf_profiles(k,:)', 'NewVariableNames', sprintf('IMF%d', imfNumbers(k)));
end
T = addvars(T, res_profile(:), 'NewVariableNames', 'Residual');
T = addvars(T, depth1_profile(:), 'NewVariableNames', 'Depth1');
T = addvars(T, depth2_profile(:), 'NewVariableNames', 'Depth2');
excelFile = fullfile(outputFolder, 'line_profiles.xlsx');
writetable(T, excelFile, 'Sheet', 'ProfileData');
fprintf('Excel file saved: %s\n', excelFile);

% 3. Save as text file (space/tab separated with header)
txtFile = fullfile(outputFolder, 'line_profiles.txt');
fid = fopen(txtFile, 'w');
fprintf(fid, '# Line profile data\n');
fprintf(fid, '# Start point (col,row): %.4f, %.4f\n', pt1(1), pt1(2));
fprintf(fid, '# End point (col,row): %.4f, %.4f\n', pt2(1), pt2(2));
fprintf(fid, '# Sampling step (pixels): %.2f\n', stepSize);
fprintf(fid, '# Number of samples: %d\n', numSamples);
fprintf(fid, '# Columns: Distance(pixels)');
fprintf(fid, ' Original');
for k = 1:numIMFs
    fprintf(fid, ' IMF%d', imfNumbers(k));
end
fprintf(fid, ' Residual Depth1 Depth2\n');
for i = 1:numSamples
    fprintf(fid, '%.6f', dist(i));
    fprintf(fid, ' %.6f', orig_profile(i));
    for k = 1:numIMFs
        fprintf(fid, ' %.6f', imf_profiles(k,i));
    end
    fprintf(fid, ' %.6f %.6f %.6f\n', res_profile(i), depth1_profile(i), depth2_profile(i));
end
fclose(fid);
fprintf('Text file saved: %s\n', txtFile);

% 4. Save coordinates of each sample point (x=col, y=row)
coordFile = fullfile(outputFolder, 'line_coordinates.txt');
dlmwrite(coordFile, [x_coords(:), y_coords(:)], 'delimiter', '\t', 'precision', '%.6f');
fprintf('Coordinates saved: %s\n', coordFile);

%% ==================== FINAL MESSAGE ====================
fprintf('\n===== ALL TASKS COMPLETED SUCCESSFULLY =====\n');
fprintf('All results are in:\n  %s\n', outputFolder);