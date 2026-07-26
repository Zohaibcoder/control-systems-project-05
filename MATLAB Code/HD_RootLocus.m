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
