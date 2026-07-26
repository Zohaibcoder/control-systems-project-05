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
%% Final Comparison 

K_Best = 0.1;
t = 0:0.1:100;

T_rl = feedback(K_Best*G,1);
S_rl = stepinfo(5*T_rl,"SettlingTimeThreshold",0.05);
fprintf('=== ROOT LOCUS CONTROLLER (K=0.1) ===\n')
fprintf('Rise Time:       %.2fs\n'  , S_rl.RiseTime)
fprintf('Settling Time:   %.2fs\n'  , S_rl.SettlingTime)
fprintf('Overshoot:       %.2f%%\n' , S_rl.Overshoot)
fprintf('Undershoot:      %.2f%%\n' , S_rl.Undershoot)
fprintf('Undershoot:      %.2f%%\n' , S_rl.Undershoot)
fprintf('SS Pitch:        %.3f(deg) (SSE = %.1f%%)\n', ...
    S_rl.Peak,5-S_rl.Peak/5*100)

%% Compare all the Controllers in one Plant 
figure(1)
t = 0:0.1:100;

% Open Loop
[y_ol,t_ol] = step(7.16*G/dcgain(G)*5,t);

% Root Locus 
[y_rl,t_rl] = step(5*T_rl,t);

% PID Tune
C_pid = pid(0.264, 0.0372, 0.455);
T_pid = feedback(C_pid*G,1);
[y_pid,t_pid] = step(5*pid,t);


plot(t_ol, y_ol, 'm', 'LineWidth', 2); hold on
plot(t_rl, y_rl, 'b', 'LineWidth', 2); 
plot(t_pid, y_pid, 'r', 'LineWidth', 2)
yline(5, 'k--', 'LineWidth', 1.5)
legend('Open Loop','Root Locus K=0.1', 'PID (pidtune)', 'Reference 5°')
title('Open Loop vs Root Locus vs PID Controller Comparison')
xlabel('Time (s)'); ylabel('Pitch Angle (degrees)'); grid on