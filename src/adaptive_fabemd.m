function [imfs, info] = adaptive_fabemd(image, max_modes, initial_radius)
% ADAPTIVE_FABEMD
% Final adaptive selection based on:
% 1. Extrema density (primary criterion)
% 2. Noise index override
% 3. Gradient ratio fallback for noisy data

image = double(image);

[rows, cols] = size(image);

%% Compute gradient ratio

[dx, dy] = gradient(image);

data_range = max(image(:)) - min(image(:));

gradient_rms = sqrt(mean(dx(:).^2 + dy(:).^2));

gradient_ratio = gradient_rms / data_range;

%% Compute extrema density

SE = strel('square',3);

max_map = image >= imdilate(image, SE);
min_map = image <= imerode(image, SE);

num_extrema = nnz(max_map) + nnz(min_map);

extrema_density = num_extrema / (rows * cols);

%% Compute noise index (FFT based)

F = fftshift(abs(fft2(image)));

hf_mask = false(size(F));

hf_mask(round(rows*0.25):round(rows*0.75), ...
        round(cols*0.25):round(cols*0.75)) = true;

noise_index = mean(F(~hf_mask),'all') / mean(F(:),'all');

%% Thresholds (validated from your datasets)

noise_threshold   = 0.25;
extrema_threshold = 0.02;
gradient_threshold = 0.04;

%% Decision logic

if noise_index > noise_threshold
    
    % noisy → ignore extrema density
    
    if gradient_ratio > gradient_threshold
        
        fprintf('Noisy data with structured gradient.\n');
        fprintf('Using ORIGINAL REGULARIZED FABEMD.\n');
        
        imfs = fabemd_regularized(image, max_modes, initial_radius);
        
        info.mode = 'original_regularized';
        
    else
        
        fprintf('Noisy data with low spatial structure.\n');
        fprintf('Using ORIGINAL BASIC FABEMD.\n');
        
        imfs = fabemd_basic(image, max_modes, initial_radius);
        
        info.mode = 'original_basic';
        
    end
    
else
    
    % clean data → extrema reliable
    
    if extrema_density > extrema_threshold
        
        fprintf('Clean data with high extrema density.\n');
        fprintf('Using ORIGINAL REGULARIZED FABEMD.\n');
        
        imfs = fabemd_regularized(image, max_modes, initial_radius);
        
        info.mode = 'original_regularized';
        
    else
        
        fprintf('Clean data with low extrema density.\n');
        fprintf('Using ORIGINAL BASIC FABEMD.\n');
        
        imfs = fabemd(image, max_modes, initial_radius);
        
        info.mode = 'original_basic';
        
    end
    
end

%% Store all diagnostics

info.gradient_ratio = gradient_ratio;
info.extrema_density = extrema_density;
info.noise_index = noise_index;

info.gradient_rms = gradient_rms;
info.data_range = data_range;
info.num_extrema = num_extrema;

info.noise_threshold = noise_threshold;
info.extrema_threshold = extrema_threshold;
info.gradient_threshold = gradient_threshold;

end