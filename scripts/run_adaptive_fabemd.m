%% RUN_ADAPTIVE_FABEMD (FINAL FULL DIAGNOSTIC VERSION)

clc;
clear;
close all;

%% Select MAT file

[file,path] = uigetfile('*.mat','Select MAT file');

if isequal(file,0)
    return;
end

data = load(fullfile(path,file));

vars = fieldnames(data);

matrix_vars = {};

for i=1:length(vars)
    
    value = data.(vars{i});
    
    if isnumeric(value) && ismatrix(value) && min(size(value))>10
        
        matrix_vars{end+1} = vars{i};
        
    end
    
end

if isempty(matrix_vars)
    error('No valid matrix found.');
end

%% Select variable

if length(matrix_vars)==1
    
    selected_var = matrix_vars{1};
    
else
    
    fprintf('\nAvailable matrices:\n');
    
    for i=1:length(matrix_vars)
        fprintf('%d) %s\n',i,matrix_vars{i});
    end
    
    idx = input('Select matrix number: ');
    
    selected_var = matrix_vars{idx};
    
end

image = double(data.(selected_var));

[rows,cols] = size(image);

fprintf('Selected variable: %s\n',selected_var);
fprintf('Grid size: %d x %d\n',rows,cols);

%% Parameters

max_modes = 20;
initial_radius = 1;

%% Compute diagnostics BEFORE adaptive

[dx,dy] = gradient(image);

data_range = max(image(:)) - min(image(:));

gradient_rms = sqrt(mean(dx(:).^2 + dy(:).^2));

gradient_ratio = gradient_rms / data_range;

SE = strel('square',3);

max_map = image >= imdilate(image,SE);
min_map = image <= imerode(image,SE);

num_extrema = nnz(max_map) + nnz(min_map);

extrema_density = num_extrema / (rows*cols);

F = fftshift(abs(fft2(image)));

hf_mask = false(size(F));

hf_mask(round(rows*0.25):round(rows*0.75),...
        round(cols*0.25):round(cols*0.75)) = true;

noise_index = mean(F(~hf_mask),'all') / mean(F(:),'all');

%% Run adaptive FABEMD (USES FINAL adaptive_fabemd.m)

[imfs, info] = adaptive_fabemd(image, max_modes, initial_radius);

%% Create output folder

base = erase(file,'.mat');

output_folder = fullfile(path,[base '_AdaptiveFABEMD']);

if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

%% Save original

save(fullfile(output_folder,'Original.mat'),'image');

figure;
imagesc(image);
axis image off;
colormap(jet);
colorbar;
title('Original Data');
saveas(gcf,fullfile(output_folder,'Original.jpg'));
saveas(gcf,fullfile(output_folder,'Original.fig'));
close;

%% Save IMFs

for i=1:length(imfs)-1
    
    imf = imfs{i};
    
    save(fullfile(output_folder,...
        sprintf('IMF_%d.mat',i)),'imf');
    
    figure('Visible','off');
    imagesc(imf);
    axis image off;
    colormap(jet);
    colorbar;
    title(sprintf('IMF %d',i));
    saveas(gcf,fullfile(output_folder,...
        sprintf('IMF_%d.jpg',i)));
    saveas(gcf,fullfile(output_folder,...
        sprintf('IMF_%d.fig',i)));
    close;
    
end

%% Save residual

residual = imfs{end};

save(fullfile(output_folder,'Residual.mat'),'residual');

figure('Visible','off');
imagesc(residual);
axis image off;
colormap(jet);
colorbar;
title('Residual');
saveas(gcf,fullfile(output_folder,'Residual.jpg'));
saveas(gcf,fullfile(output_folder,'Residual.fig'));
close;

%% Depth analysis

if strcmp(info.mode,'original_basic')
    
    [depth_results, elbow] = fabemd_depth_analysis(imfs,...
        fullfile(output_folder,base));
    
else
    
    [depth_results, elbow] = fabemd_depth_analysis_regularized(imfs,...
        fullfile(output_folder,base));
    
end

%% Save metadata MAT file

metadata.file = file;
metadata.variable = selected_var;
metadata.grid_size = [rows cols];

metadata.gradient_ratio = gradient_ratio;
metadata.gradient_rms = gradient_rms;
metadata.data_range = data_range;

metadata.extrema_density = extrema_density;
metadata.num_extrema = num_extrema;

metadata.noise_index = noise_index;

metadata.method = info.mode;
metadata.elbow_imf = elbow;

metadata.max_modes = max_modes;
metadata.initial_radius = initial_radius;

metadata.date = datestr(now);

save(fullfile(output_folder,'Adaptive_Metadata.mat'),'metadata');

%% Save detailed TXT report with MODEL NAME

report_file = fullfile(output_folder,...
    ['Adaptive_Report_' base '.txt']);

fid = fopen(report_file,'w');

fprintf(fid,'========================================\n');
fprintf(fid,'Adaptive FABEMD Full Diagnostic Report\n');
fprintf(fid,'========================================\n\n');

fprintf(fid,'File: %s\n',file);
fprintf(fid,'Variable: %s\n\n',selected_var);

fprintf(fid,'Grid size: %d x %d\n\n',rows,cols);

fprintf(fid,'--- Spatial Metrics ---\n');

fprintf(fid,'Gradient ratio: %.10f\n',gradient_ratio);
fprintf(fid,'Gradient RMS: %.10f\n',gradient_rms);
fprintf(fid,'Data range: %.10f\n\n',data_range);

fprintf(fid,'Extrema density: %.10f\n',extrema_density);
fprintf(fid,'Number of extrema: %d\n\n',num_extrema);

fprintf(fid,'--- Noise Metrics ---\n');

fprintf(fid,'Noise index: %.10f\n\n',noise_index);

fprintf(fid,'--- Adaptive Decision ---\n');

fprintf(fid,'Selected method: %s\n',info.mode);
fprintf(fid,'Elbow IMF index: %d\n\n',elbow);

fprintf(fid,'Shallow sources: IMF 1 to %d\n',elbow);
fprintf(fid,'Deep sources: IMF %d to %d\n\n',elbow+1,length(imfs)-1);

fprintf(fid,'Date: %s\n',datestr(now));

fprintf(fid,'========================================\n');

fclose(fid);

%% Console output

fprintf('\n====================================\n');

fprintf('Adaptive FABEMD completed\n');

fprintf('Gradient ratio: %.6f\n',gradient_ratio);

fprintf('Extrema density: %.6f\n',extrema_density);

fprintf('Noise index: %.6f\n',noise_index);

fprintf('Selected method: %s\n',info.mode);

fprintf('Elbow IMF index: %d\n',elbow);

fprintf('Report saved as:\n%s\n',report_file);

fprintf('Output folder:\n%s\n',output_folder);

fprintf('====================================\n');