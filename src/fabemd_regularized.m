%% FILE: fabemd.m (OPTIMIZED)

function imfs = fabemd(image, max_modes, initial_extrema_radius)

if nargin < 3
    initial_extrema_radius = 2;
end
if nargin < 2
    max_modes = 15;
end

image = double(image);

% ---------- 0) Remove regional trend (2nd order) ----------
image = detrend_surface(image,2);

% ---------- 1) Light Gaussian denoising ----------
image = imgaussfilt(image,1);

residue = image;
[rows, cols] = size(residue);

% ---------- 2) Stronger Mirror Padding ----------
pad_ratio = 0.25;
pad_size  = round(pad_ratio * min(rows, cols));
residue   = padarray(residue, [pad_size pad_size], 'symmetric');

imfs = {};
extrema_radius = initial_extrema_radius;
MIN_SMOOTH = 5;

for mode = 1:max_modes

    win = 2*extrema_radius + 1;
    SE  = strel('square', win);

    max_map = residue >= imdilate(residue, SE);
    min_map = residue <= imerode(residue, SE);

    if nnz(max_map) + nnz(min_map) < 5
        break;
    end

    % -------- Robust scale estimation --------
    dmax = nn_min_distance(max_map);
    dmin = nn_min_distance(min_map);
    smoothing_distance = median([dmax dmin]);

    if ~isfinite(smoothing_distance) || smoothing_distance < MIN_SMOOTH
        smoothing_distance = MIN_SMOOTH;
    end

    smoothing_distance = 2*ceil(smoothing_distance/2)+1;
    smoothing_distance = min(smoothing_distance, floor(min(rows,cols)/3));

    % -------- Envelope construction --------
    SE2 = strel('square', smoothing_distance);

    upper_env = imdilate(residue, SE2);
    lower_env = imerode(residue, SE2);

    smooth_upper = imgaussfilt(upper_env, smoothing_distance/6);
    smooth_lower = imgaussfilt(lower_env, smoothing_distance/6);

    mean_env = (smooth_upper + smooth_lower)/2;

    new_imf = residue - mean_env;

    if mean(abs(new_imf(:))) < 1e-4
        break;
    end

    imfs{end+1} = new_imf;
    residue     = mean_env;

    extrema_radius = extrema_radius + 1;
end

imfs{end+1} = residue;

% ---------- Crop ----------
for k = 1:length(imfs)
    imfs{k} = imfs{k}(pad_size+1:end-pad_size, pad_size+1:end-pad_size);
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Helper Function: Nearest Neighbor Distance -----
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dmin = nn_min_distance(map)

[r, c] = find(map);

if numel(r) <= 1
    dmin = inf;
    return;
end

pts = [r c];

% 
if size(pts,1) > 2000
 
    idx = randperm(size(pts,1),2000);
    pts = pts(idx,:);
end

D = pdist2(pts, pts);
D(1:size(D,1)+1:end) = inf;

d_each = min(D,[],2);
dmin = median(d_each);  
end