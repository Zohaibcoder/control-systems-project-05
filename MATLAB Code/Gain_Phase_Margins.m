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
%% Find exact gain margin analytically
[Gm, Pm, Wcg, Wcp] = margin(G);
fprintf("Gain Margin      = %.4f\n",Gm);
fprintf("Phase Margin     = %.4f deg\n",Pm);
fprintf("Phase Crossover Frequency (ωpc) = %.4f rad/s\n",Wcg);
fprintf("Gain Crossover Frequency  (ωgc) = %.4f rad/s\n",Wcp);
Kcrit = Gm;
fprintf("Critical Gain = %.4f\n",Kcrit);