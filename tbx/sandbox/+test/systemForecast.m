

a1 = [1.5, 0; 0, -0.8];
a2 = [-0.1, 0; 0, 0.1];
a = [a1, a2];
A = a';

c = [10; -10];
C = c';

Sigma = eye(2);

d = [];
D = d';

Y = zeros(10, 2);
X = zeros(10, 5);
X(:, end) = 1;
U = zeros(10, 2);

YX = {Y, X};

out = var.system.forecast(A, C, YX, U);


