
N = 1e5;
a = nan(100,100,N);
b = cell(1, N);
for i = 1 : N
    x = rand(100);
    a(:,:,i) = x;
    b{i} = x;
end
bb = cat(3, b{:});
