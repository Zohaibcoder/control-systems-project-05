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
%% Desired Requirements 
% To see if our original rootlocus passes through our 
% required/desired performance specifications or not?

% 1.POS must be less than 10 
% 2.Settling Time must be less than 10s

figure(1)
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