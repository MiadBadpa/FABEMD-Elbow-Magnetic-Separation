%% FILE: fabemd.m
function imfs = fabemd(image, max_modes, initial_extrema_radius)

if nargin < 3
    initial_extrema_radius = 1;
end
if nargin < 2
    max_modes = 10;
end

residue = double(image);
[rows, cols] = size(residue);

% --------- Mirror Padding (Edge Effect Mitigation) ----------
pad_ratio = 0.1;
pad_size  = round(pad_ratio * min(rows, cols));
residue   = padarray(residue, [pad_size pad_size], 'symmetric');

imfs = {};
extrema_radius = initial_extrema_radius;
MIN_SMOOTH = 3;

for mode = 1:max_modes

    % ---- 1) Extrema detection ----
    win = 2*extrema_radius + 1;
    SE  = strel('square', win);

    max_map = residue >= imdilate(residue, SE);
    min_map = residue <= imerode(residue, SE);

    if nnz(max_map) + nnz(min_map) < 3
        break;
    end

    % ---- 2) Adaptive smoothing scale ----
    dmax = nn_min_distance(max_map);
    dmin = nn_min_distance(min_map);
    smoothing_distance = min(dmax, dmin);

    if ~isfinite(smoothing_distance) || smoothing_distance <= 0
        smoothing_distance = MIN_SMOOTH;
    end

    smoothing_distance = 2*ceil(smoothing_distance/2)+1;
    smoothing_distance = max(smoothing_distance, MIN_SMOOTH);

    % ---- 3) Envelope construction ----
    SE2 = strel('square', smoothing_distance);

    upper_env = imdilate(residue, SE2);
    lower_env = imerode(residue, SE2);

    kernel = ones(smoothing_distance) / (smoothing_distance^2);

    smooth_upper = conv2(upper_env, kernel, 'same');
    smooth_lower = conv2(lower_env, kernel, 'same');

    mean_env = (smooth_upper + smooth_lower)/2;
    new_imf  = residue - mean_env;

    imfs{end+1} = new_imf;
    residue     = mean_env;

    if max(abs(new_imf(:))) < 1e-6
        break;
    end
end

imfs{end+1} = residue;

% --------- Crop Back to Original Size ----------
for k = 1:length(imfs)
    imfs{k} = imfs{k}(pad_size+1:end-pad_size, pad_size+1:end-pad_size);
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------- Helper Function -------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dmin = nn_min_distance(map)

[r, c] = find(map);

if numel(r) <= 1
    dmin = inf;
    return;
end

pts = [r c];

try
    D = pdist2(pts, pts);
    D(1:size(D,1)+1:end) = inf;
    d_each = min(D,[],2);
    dmin = min(d_each);
catch
    Dvec = pdist(pts);
    if isempty(Dvec)
        dmin = inf;
    else
        Dmat = squareform(Dvec);
        Dmat(1:size(Dmat,1)+1:end) = inf;
        d_each = min(Dmat,[],2);
        dmin = min(d_each);
    end
end

end