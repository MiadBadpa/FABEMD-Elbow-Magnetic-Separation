%% ADD SHARED NOISE TO THREE SEPARATE FILES (WITH IMAGE SAVING)

clc; clear; close all;

%% -------------------- 1) Select TOTAL file --------------------
[file1,path1] = uigetfile('*.mat','Select TOTAL data file');
if isequal(file1,0); return; end
data1 = load(fullfile(path1,file1));

%% -------------------- 2) Select DEPTH 1 file --------------------
[file2,path2] = uigetfile('*.mat','Select DEPTH 1 data file');
if isequal(file2,0); return; end
data2 = load(fullfile(path2,file2));

%% -------------------- 3) Select DEPTH 2 file --------------------
[file3,path3] = uigetfile('*.mat','Select DEPTH 2 data file');
if isequal(file3,0); return; end
data3 = load(fullfile(path3,file3));

%% -------------------- 4) Extract First 2D Matrix --------------------
dt_total = extract_first_matrix(data1);
dt_d1    = extract_first_matrix(data2);
dt_d2    = extract_first_matrix(data3);

if ~isequal(size(dt_total), size(dt_d1), size(dt_d2))
    error('All three datasets must have identical dimensions.');
end

[rows,cols] = size(dt_total);

%% -------------------- 5) Create Output Folder --------------------
base_total = erase(file1,'.mat');
output_folder = fullfile(path1, base_total);

if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

%% -------------------- 6) Build Shared Noise --------------------

noise_level = 0.05;   
sigma = noise_level * std(dt_total(:));

white_noise = sigma * randn(rows,cols);

corr_raw = randn(rows,cols);
corr_noise = imgaussfilt(corr_raw,6);
corr_noise = corr_noise/std(corr_noise(:))*sigma;

line_noise = sigma*0.5*randn(rows,1);
line_noise = repmat(line_noise,1,cols);

[x,y] = meshgrid(1:cols,1:rows);
trend_strength = 0.3 * max(abs(dt_total(:)));

trend = trend_strength*( ...
      0.00001*x.^2 ...
    - 0.000015*y.^2 ...
    + 0.00002*x.*y );

noise_matrix = white_noise + corr_noise + line_noise + trend;

%% -------------------- 7) Add SAME Noise --------------------
total_noisy = dt_total + noise_matrix;
d1_noisy    = dt_d1    + noise_matrix;
d2_noisy    = dt_d2    + noise_matrix;

%% -------------------- 8) Save MAT Files --------------------
save(fullfile(output_folder,'Total_Noisy.mat'),'total_noisy');
save(fullfile(output_folder,'Depth1_Noisy.mat'),'d1_noisy');
save(fullfile(output_folder,'Depth2_Noisy.mat'),'d2_noisy');
save(fullfile(output_folder,'Shared_Noise_Matrix.mat'),'noise_matrix');

%% -------------------- 9) Save Individual Images --------------------
save_image(noise_matrix, fullfile(output_folder,'Shared_Noise.jpg'), 'Shared Noise');
save_image(total_noisy, fullfile(output_folder,'Total_Noisy.jpg'), 'Noisy Total');
save_image(d1_noisy, fullfile(output_folder,'Depth1_Noisy.jpg'), 'Noisy Depth 1');
save_image(d2_noisy, fullfile(output_folder,'Depth2_Noisy.jpg'), 'Noisy Depth 2');

%% -------------------- 10) Save Comparison Figure --------------------
figure('Position',[100 100 1200 400]);

subplot(1,3,1)
imagesc(dt_total); axis image off;
title('Original Total'); colorbar

subplot(1,3,2)
imagesc(total_noisy); axis image off;
title('Noisy Total'); colorbar

subplot(1,3,3)
imagesc(noise_matrix); axis image off;
title('Shared Noise'); colorbar

colormap(jet);

saveas(gcf, fullfile(output_folder,'Comparison.jpg'));
close;

fprintf('\nAll outputs (MAT + images) saved in folder: %s\n', output_folder);

%% -------------------- Helper Functions --------------------
function mat = extract_first_matrix(data_struct)
vars = fieldnames(data_struct);
for i = 1:length(vars)
    val = data_struct.(vars{i});
    if isnumeric(val) && ndims(val)==2
        mat = double(val);
        return;
    end
end
error('No 2D numeric matrix found in MAT file.');
end

function save_image(matrix, filename, title_text)
figure('Visible','off');
imagesc(matrix);
axis image off;
colormap(jet);
colorbar;
title(title_text);
saveas(gcf, filename);
close;
end