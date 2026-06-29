function dmin = nn_min_distance(map)
% Compute nearest-neighbor extrema distance

[r,c] = find(map);

if numel(r)<=1
    dmin=inf;
    return;
end

pts=[r c];

D=pdist2(pts,pts);

D(1:size(D,1)+1:end)=inf;

dmin=min(min(D));

end