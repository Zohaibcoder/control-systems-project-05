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
%% Analytical Test 

k_values = [0.1,0.2,0.35,0.4];

for i = 1:length(k_values)
    k_Test = k_values(i);
    T_Test = feedback(k_Test*G,1);
    S = stepinfo(5*T_Test);
    CL_poles = pole(T_Test);
    fprintf('K = %.2f: ST = %.4f RT = %.4f OS = %.4f US = %.4f Peak = %.4f ', ...
        k_Test,S.SettlingTime,S.RiseTime,S.Overshoot,S.Undershoot,S.Peak)
    fprintf('\n   Poles: %.4f , %.4f+%.4fj\n\n', ...
        real(CL_poles(1)), real(CL_poles(2)), imag(CL_poles(2)))
end

%% Plot all four step responses together
figure(1)
k_values = [0.1,0.2,0.35,0.4];
t = 0:0.1:100;
colors = {'r','b','g','m'};
for i = 1:length(k_values)
    k_Test = k_values(i);
    T_Test = feedback(k_Test*G,1);
    [y,t_out] = step(5*T_Test,t);
    plot(t_out,y,colors{i},'LineWidth',2)
    hold on
end

title('Root Locus Controller---Different Gain Values')
xlabel('Time(s)') ; ylabel('Pitch Angle (degrees)') ; grid on
yline(5,'k--','Reference 5°')
legend('K=0.1','K=0.2','K=0.35','K=0.4','Reference 5°')
