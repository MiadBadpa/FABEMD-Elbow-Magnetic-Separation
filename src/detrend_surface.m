function out = detrend_surface(data, order)
% Remove polynomial trend from data

[rows,cols] = size(data);

[x,y] = meshgrid(1:cols,1:rows);

x=x(:); y=y(:); z=data(:);

if order==1
    
    G=[ones(size(x)) x y];
    
else
    
    G=[ones(size(x)) x y x.^2 x.*y y.^2];
    
end

m = G\z;

trend = reshape(G*m,rows,cols);

out = data - trend;

end