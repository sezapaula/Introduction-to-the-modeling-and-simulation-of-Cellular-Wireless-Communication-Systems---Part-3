clear alclc;
%% Definição de parâmetros gerais da simulação
tSQUARE = 1000;  % tamanho do grid em M
bT = 10^8;  % largura de banda em Hz
nChannel = 1;  % número de canais (ajuste conforme necessário)
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

nmrSetups = 100;  % numero de repeticoes da simulacao

% Geracao de posicoes aleatorias dos usuarios
UElocations = (rand(nmrSetups, nmrUE) + 1i * rand(nmrSetups, nmrUE)) * tSQUARE;

%% Definição de parâmetros do modelo de path
% Cálculo de BC (largura de banda de cada canal)
bc = bT / nChannel;

% Potência do ruído
pN = k0 * bc;

% Sombreamento e fast fading
shadow = lognrnd(0, 2, nmrSetups, nmrUE);
rayleigh_fading = raylrnd(1/sqrt(2), [nmrSetups, nmrUE, nChannel]); %Componente de fast fading


% Função para cálculo da potência recebida
PReceiver = @(hor_distances, shadow) shadow .* UEpot .* (c ./ hor_distances.^a);  % potência recebida

%% Lógica do cálculo de SINR, potência e interferÊncias
% Armazenamento de valores
sinr = [];

% Cálculo das potências recebidas e alocação de canais
for i = 1:nmrSetups
    pot_values = zeros(nmrAP, nmrUE);  % NmrAP X NmrUE

    for ch=1:nChannel
        for j = 1:nmrUE
            distances = abs(UElocations(i, j) - APcellular(:));  % Distância entre o usuário e todos os APs
            pot_values(:, j) = PReceiver(distances, shadow(i, j)).*rayleigh_fading(i,j,ch).^2;  % Potência recebida
        end
    end
    
    % Cálculo das maiores potências de cada AP para cada usuário
    maiores_valores = max(pot_values, [], 1);  % Maior potência por usuário
    
    % Distribuição balanceada de usuários nos canais
    user_channels = zeros(1, nmrUE);
    users_per_channel = floor(nmrUE / nChannel);  % Quantos usuários por canal, de forma equilibrada
    remainder_users = mod(nmrUE, nChannel);  % Sobras de usuários
    
    % Distribuicao de usuarios nos canais
    idx = 1;  % indice para os usuarios
    for ch = 1:nChannel
        num_users_in_channel = users_per_channel + (ch <= remainder_users);  % Atribui usuario da sobra aos primeiros canais
        user_channels(idx:idx+num_users_in_channel-1) = ch;  % Atribui o canal aos usuarios
        idx = idx + num_users_in_channel;  % Atualizacao de indice para o usuario seguinte
    end
    
    % Contadores para usuarios por canal
    for f = 1:nmrAP
        for u = 1:nmrUE
            % Determina o canal que o usuário 'u' está usando
            channel = user_channels(u);
            
            % Calcula a interferencia do canal (potencia de outros usuarios no mesmo canal)
            interference_power = 0;
            for ch1 = 1:nmrUE
                if user_channels(ch1) == channel && ch1 ~= u  % Se o canal for o mesmo, e não for o proprio usuario
                    interference_power = interference_power + pot_values(f, ch1);
                end
            end
            
            % Calculo da SINR
            sinr_value = maiores_valores(u) / (interference_power + pN);
            sinr = [sinr, sinr_value];
        end
    end
end

%% Logica do calculo de capacidades
conv_sinr = reshape(sinr,[nmrAP*nmrSetups,nmrUE]);
Shannon=zeros(nmrSetups,nmrUE);

for x = 1:nmrUE
    for y = 1:nmrSetups*nmrAP
        Shannon(y, x) = bc * log2(1 + conv_sinr(y, x));  
    end
end

media=mean(sum(Shannon,2)); %Calculo da média da sum-capacity

Shannon_ord=reshape(Shannon,1,[]);
%% Eficiencia Espectral
efi=sum(Shannon,2);
res=efi/bT;

%% Cálculos dos percentis
porcento_10 = prctile(Shannon_ord, 10);  % percentil 10
fprintf('Porcentil 10: %.4f\n', porcento_10 * 1e-6);

porcento_50 = prctile(Shannon_ord, 50);  % percentil 50
fprintf('Porcentil 50: %.4f\n', porcento_50 * 1e-6);

porcento_90 = prctile(Shannon_ord, 90);  % percentil 90
fprintf('Porcentil 90: %.4f\n', porcento_90 * 1e-6);

percentile_efi=prctile(res,10);
fprintf('Eficiencia espectral:%.4f\n',percentile_efi);

fprintf('Média da soma das capacidades:%.3f\n',media*1e-6);

