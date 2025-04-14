function s = unvech(v)

l = length(v);
n = (sqrt(1 + 8*l) - 1) / 2;

ind = 1:n;
trilInd = ind' >= ind;

s = zeros(n);
s(trilInd) = v;

end