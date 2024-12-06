% Parametros da simulacao
clear allclc;
f = 10; % Frequencia em Hz
fs = 10000; % Frequencia de amostragem em Hz
t = 0:1/fs:1; % Vetor de tempo de 0 a 1 segundo

% Definindo os atrasos
delay_start = 10e-3; % 10 ms
delay_end = 54e-3; % 54 ms

% Criacao da figura para animacao
figure('Position', [100, 100, 800, 600]); % Tamanho fixo da figura
xlabel('Time (s)');
ylabel('Amplitude');
title('Animação do Sinal Combinado');
grid on;
hold on;
%% Configurações de fonte para LaTeX
set(gca, 'FontName', 'latex');
set(findall(gcf, 'Type', 'text'), 'FontName', 'latex');
% Preparar para salvar o GIF
gif_filename = 'combined_signal_animation.gif';

% Loop para criar a animacao
for delay_ms = delay_start * 1000:1:delay_end * 1000
    delay = delay_ms * 1e-3; % Convertendo ms para segundos
    
    % Sinal direto
    signal_los = sin(2 * pi * f * t);
    
    % Sinal refletido com atraso
    sinal_delay = sin(2 * pi * f * (t + delay)); 
    
    % Sinal combinado
    combined_signal = signal_los + sinal_delay;
    
    % Limpar a figura
    clf;
    
    % Plotagem dos sinais
    plot(t, signal_los, 'b', 'DisplayName', 'Direct path');
    hold on;
    plot(t, sinal_delay, 'r--', 'DisplayName', 'Delayed path');
    plot(t, combined_signal, 'k', 'DisplayName', 'Combined Signal');
    
    % Atualizacao de título e legendas (para cada figura para formar o gif)
    title(sprintf('Delay: %.1f ms', delay_ms));
    ylim([-2 2]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    legend;
    grid on;
    % Configurações de fonte para LaTeX
    set(gca, 'FontName', 'latex');
    set(findall(gcf, 'Type', 'text'), 'FontName', 'latex');
    
    % Captura o quadro atual
    frame = getframe(gcf); % Captura a figura atual
    im = frame2im(frame); % Converte o quadro em imagem
    [A,map] = rgb2ind(im,256); % Converte a imagem em índice de cores
    
    % Salva a imagem no arquivo GIF
    if delay_ms == delay_start * 1000 % Para o primeiro quadro
        imwrite(A,map,gif_filename,'gif','LoopCount',inf,'DelayTime',0.1);
    else
        imwrite(A,map,gif_filename,'gif','WriteMode','append','DelayTime',0.1);
    end
    
    % Ajuste de pausa para visualização
    pause(0.1); 
end

disp(['Nossa animacao sera salva como: ', gif_filename]);
