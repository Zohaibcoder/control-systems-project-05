clc , clear all ; 
%% System Parameters
K  = 1.282;
tau = -1.0;
a2 = 1.935;
a1 = 0.987;
a0 = 0.179;
%% Transfer Function 
num = [K*tau K];
den = [1 a2 a1 a0];
G = tf(num,den);

%% Specification of root loucs
G = tf([-1.282 1.282],[1 1.935 0.987 0.179]);

p = pole(G)
z = zero(G)

n = length(p);
m = length(z);

asymtotes = n-m

centroid = (sum(p)-sum(z))/asymtotes

angles = (2*(0:n-m-1)+1)*180/asymtotes

% Crossing Point on the Img axis
syms K w real

eq1 = -1.935*w^2 + 0.179 + 1.282*K;
eq2 = -w^3 + (0.987 - 1.282*K)*w;

sol = solve([eq1==0, eq2==0],[K,w],'Real',true);

K = double(sol.K)
w = double(sol.w)


% Break away/in point 

syms s

N = s^3 + 1.935*s^2 + 0.987*s + 0.179;
D = 1.282*(s - 1);

K = N/D;

dK = simplify(diff(K,s))

sol = solve(dK==0,s)

double(sol)