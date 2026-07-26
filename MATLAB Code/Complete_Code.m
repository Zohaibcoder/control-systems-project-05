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
%% Root Locus 
figure(1)
rlocus(G)
sgrid
title("Root Locus - Aircraft Pitch Plant")
grid on 

% =========================================================================
% HIGH-CONTRAST SGRID & THICK BRANCH ENHANCEMENT
% =========================================================================
% 1. Separate Grid lines from Root Locus Branches
allLines = findall(gcf, 'Type', 'line');
for k_values = 1:length(allLines)
    if strcmp(allLines(k_values).LineStyle, '-') 
        % THICKEN ROOT LOCUS BRANCHES
        set(allLines(k_values), 'LineWidth', 2.5); 
    else
        % DARKEN & SLIM DOWN S-PLANE GRID LINES
        set(allLines(k_values), 'Color', [0.35 0.35 0.35], 'LineWidth', 0.9);
    end

    % Enlarge pole 'x' and zero 'o' markers if attached to the line
    if ~strcmp(allLines(k_values).Marker, 'none')
        set(allLines(k_values), 'MarkerSize', 8, 'LineWidth', 2.0);
    end
end

% 2. Clean, readable damping and frequency text
allText = findall(gcf, 'Type', 'text');
for k_values = 1:length(allText)
    set(allText(k_values), 'Color', [0.15 0.15 0.15], 'FontWeight', 'bold', 'FontSize', 9);
end

% 3. Crisp axis frame
ax = findall(gcf, 'Type', 'axes');
if ~isempty(ax)
    set(ax, 'LineWidth', 1.2, 'XColor', [0 0 0], 'YColor', [0 0 0]);
end
% =========================================================================

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
%% Find exact gain margin analytically
[Gm, Pm, Wcg, Wcp] = margin(G);
fprintf("Gain Margin      = %.4f\n",Gm);
fprintf("Phase Margin     = %.4f deg\n",Pm);
fprintf("Phase Crossover Frequency (ωpc) = %.4f rad/s\n",Wcg);
fprintf("Gain Crossover Frequency  (ωgc) = %.4f rad/s\n",Wcp);
Kcrit = Gm;
fprintf("Critical Gain = %.4f\n",Kcrit);

%% Desired Requirements 
% To see if our original rootlocus passes through our 
% required/desired performance specifications or not?

% 1.POS must be less than 10 
% 2.Settling Time must be less than 10s

figure(2)
rlocus(G)
sgrid
title("Root Locus with Desired Pole Region")
grid on 
hold on 

% -------------             POS line      ----------------------
% By formula the zeta = 0.59
thetha = acos(0.59);
r = linspace(0,2,100);
% Drawing the radian line on root locus for zeta = 0.59
plot(-r*cos(thetha),r*sin(thetha),'k--','LineWidth',2)
plot(-r*cos(thetha),-r*sin(thetha),'k--','LineWidth',2)

% -------------          Settling Time Line     -------------
ts = 10;
sigma = 4/ts;
plot([-sigma,-sigma],[-2,2],'m--','LineWidth',2)


legend('Root Locus','Damping ratio ζ=0.59','Damping ratio ζ=0.59','Settling time σ=0.4')
xlim([-1.5 1.5]); ylim([-1 1])

%%
figure(3)
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
figure(4)
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
figure(5)
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