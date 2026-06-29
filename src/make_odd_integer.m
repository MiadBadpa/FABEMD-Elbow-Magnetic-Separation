function n = make_odd_integer(x)

n = round(x);

if mod(n,2)==0
    n = n + 1;
end

n = max(n,3);

end