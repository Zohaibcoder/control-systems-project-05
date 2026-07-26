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
%% Interactive Selction of Gain
figure(1)
rlocus(G)
sgrid
title('Root Locus — Click on Phugoid branch closest to desired region')
grid on
xlim([-1.5 0.5]); ylim([-1 1])
[K_selected, poles_selected] = rlocfind(G)

T_rl = feedback(K_selected * G, 1);
figure(4)
step(5 * T_rl, 100)
title('Root Locus Controller Step Response')
grid on
stepinfo(5*T_rl)