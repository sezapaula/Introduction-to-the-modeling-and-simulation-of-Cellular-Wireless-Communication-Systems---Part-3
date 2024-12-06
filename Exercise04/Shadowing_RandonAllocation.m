clear;
clc;
%% Definição de parâmetros gerais da simulação
tSQUARE = 1000;  % tamanho do grid em M
bT = 10^8;  % largura de banda em Hz
nChannel =1;  % número de canais
UEpot = 1;  % potência de transmissão do usuário
c = 10^-4;  % constante do modelo de propagação
nmrUE = 13;  % número de usuários
nmrAP = 64;  % número de APs
k0 = 10^-20; % constante do ruído
a = 4;  % expoente de pathloss

%% Definição da posição dos APs e dos usuários
APperdim = sqrt(nmrAP); %Número de APs "por linha"

% Cria o vetor APcellular
APcellular = linspace(tSQUARE / APperdim, tSQUARE, round(APperdim)) - tSQUARE / (2 * APperdim);

% Forma a matriz APcellular
APcellular = (repmat(APcellular, round(APperdim), 1) + 1j * repmat(APcellular.', 1, round(APperdim))) * 1;

nmrSetups = 1000;  % número de repetições da simulação

% Geração de posições aleatórias para os usuários
UElocations = (rand(nmrSetups, nmrUE) + 1i * rand(nmrSetups, nmrUE)) * tSQUARE;

%% Definição de parâmetros do modelo de path
% Cálculo de BC (largura de banda de cada canal)
bc = bT / nChannel;

% Potência do ruído
pN = k0 * bc;

% Sombreamento
shadow = lognrnd(0, 2, nmrSetups, nmrUE);

% Função para cálculo da potência recebida
PReceiver = @(hor_distances, shadow) shadow .* UEpot .* (c ./ hor_distances.^a);  % potência recebida

%% Lógica do cálculo de SINR, potência e interferÊncias
% Armazenamento de valores
sinr = [];

% Cálculo das potências recebidas e alocação de canais
for i = 1:nmrSetups
    pot_values = zeros(nmrAP, nmrUE);  % NmrAP X NmrUE
    
    for j = 1:nmrUE
        distances = abs(UElocations(i, j) - APcellular(:));  % Distância entre o usuário e todos os APs
        pot_values(:, j) = PReceiver(distances, shadow(i, j));  % Potência recebida
    end
    
    % Cálculo das maiores potências de cada AP para cada usuário
    maiores_valores = max(pot_values, [], 1);  % Maior potência por usuário
    
    % Alocação aleatória de canais para os usuários
    user_channels = randi([1, nChannel], 1, nmrUE);
    
    % Contadores para usuários por canal
    for f = 1:nmrAP
        for u = 1:nmrUE
            % Determina o canal que o usuário 'u' está usando
            channel = user_channels(u);
            
            % Calcula a interferência do canal (potência de outros usuários no mesmo canal)
            interference_power = 0;
            for ch1 = 1:nmrUE
                if user_channels(ch1) == channel && ch1 ~= u  % Se o canal for o mesmo, e não for o próprio usuário
                    interference_power = interference_power + pot_values(f, ch1);
                end
            end
            
            % Cálculo da SINR (Sinal sobre Interferência + Ruído)
            sinr_value = maiores_valores(u) / (interference_power + pN);
            sinr = [sinr, sinr_value];
        end
    end
end



% Cálculo da capacidade de Shannon
Shannon = zeros(size(sinr));  %Essa lógiga precisará ser adaptada no cálculo de sum-capacity
for x = 1:length(sinr)
    Shannon(x) = bc * log2(1 + sinr(x));
end

%% Cálculos dos percentis
porcento_10 = prctile(Shannon, 10);  % percentil 10
fprintf('Porcentil 10: %.4f\n', porcento_10 * 1e-6);

porcento_50 = prctile(Shannon, 50);  % percentil 50
fprintf('Porcentil 50: %.4f\n', porcento_50 * 1e-6);

porcento_90 = prctile(Shannon, 90);  % percentil 90
fprintf('Porcentil 90: %.4f\n', porcento_90 * 1e-6);
