function v = vech(s)

n   = size(s, 1);
ind = 1:n;
trilInd = ind' >= ind;
v = s(trilInd);

end