%% Parametros da simulacao
clear allclc;
f = 10; % Frequency in Hz
fs = 10000; % Sample frequency em Hz
t = 0:1/fs:1; % Vetor de tempo de 0 a 1 segundo
delay_1 = 10e-3; % em seconds
delay_2 = 54e-3; %  em segundos

%% Lógica dos sinais 
% situacao de los
signal_los = sin(2 * pi * f * t);

% Cenário 1: Receptor em posição 1 com atraso de 10 ms

sinal_delay_1 = sin(2 * pi * f * (t + delay_1)); % Sinal com atraso

% Sinal combinado 1
combined_signal_1 = signal_los + sinal_delay_1;

% Plota os sinais em posição 1
figure;

% Sinais LOS e refletido
subplot(2, 1, 1);
plot(t, signal_los, 'b', 'DisplayName', 'Direct path');
hold on;
plot(t, sinal_delay_1, 'r--', 'DisplayName', 'Delayed path 1');
plot(t, combined_signal_1, 'k','DisplayName','Combined Signal');
title('Multipath Fading Simulation');
xlabel('Time (s)');
ylabel('Amplitude');
legend;
grid on;
set(gca, 'FontName', 'latex');
set(findall(gcf, 'Type', 'text'), 'FontName', 'latex');


% Cenário 2: Receptor em posição 2 com atraso de 54 ms

sinal_delay_2 = sin(2 * pi * f * (t + delay_2)); % Sinal refletido

% Combined signal 2
combined_signal_2 = signal_los + sinal_delay_2;

% Plota os sinais em posição 2


% Sinais LOS e refletido
subplot(2, 1, 2);
plot(t, signal_los, 'b', 'DisplayName', 'Direct path');
hold on;
plot(t, sinal_delay_2, 'r--', 'DisplayName', 'Delayed path 2');
plot(t, combined_signal_2, 'k','DisplayName', 'Combined signal');
title('Multipath Fading Simulation');
xlabel('Time (s)');
ylabel('Amplitude');
ylim([-2 2]);
legend;
grid on;

% Configurações de fonte para LaTeX
set(gca, 'FontName', 'latex');
set(findall(gcf, 'Type', 'text'), 'FontName', 'latex');

% Salvar a figura em formato EPS
%print(gcf, 'multipath_fading_simulation.eps', '-depsc');
