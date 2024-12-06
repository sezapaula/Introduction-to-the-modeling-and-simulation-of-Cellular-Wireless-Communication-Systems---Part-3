clear allclc;

%% Definição dos parâmetros gerais da simulação
tSQUARE = 1000;  % tamanho do grid em M
bT = 10^8;  % largura de banda em Hz
nChannel = 1;  % número de canais
UEpot = 1;  % potência de transmissão do usuário
c = 10^-4;  % constante do modelo de propagação
nmrUE = 13;  % número de usuários
nmrAP = 64;  % número de APs
k0 = 10^-20; % constante do ruído
a = 4;  % expoente de pathloss

%% Lógica da formação das posições dos APs e usuários
APperdim = sqrt(nmrAP); % Essa linha coloca a quantidade de APs ao longo da 'linha' do Grid

% Essa linha cria o vetor APcellular
APcellular = linspace(tSQUARE / APperdim, tSQUARE, round(APperdim)) - tSQUARE / (2 * APperdim);

% Essa linha forma a matriz APcellular
APcellular = (repmat(APcellular, round(APperdim), 1) + 1j * repmat(APcellular.', 1, round(APperdim))) * 1;

nmrSetups = 100;  % número de repetições da simulação

% Geração de posições aleatórias para os usuários
UElocations = (rand(nmrSetups, nmrUE) + 1i * rand(nmrSetups, nmrUE)) * tSQUARE;

%% Outros parâmetros importantes
% Cálculo de BC (largura de banda de cada canal)
bc = bT / nChannel;

% Potência do ruído
pN = k0 * bc;

% Sombreamento e fast fading
shadow = lognrnd(0, 2, nmrSetups, nmrUE); %Componente de low fading
rayleigh_fading = raylrnd(1/sqrt(2), [nmrSetups, nmrUE, nChannel]); %Componente de fast fading

% Função para cálculo da potência recebida
PReceiver = @(hor_distances, shadow) shadow .* UEpot .* (c ./ hor_distances.^a);  % potência recebida

%% Lógica do calculo de SINR e alocação de usuários em canais aleatórios
sinr = []; %Armazenamento de valores

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
            
            % Cálculo da SINR (Interferência + Ruído)
            sinr_value = maiores_valores(u) / (interference_power + pN);
            sinr = [sinr, sinr_value];
        end
    end
end

conv_sinr = reshape(sinr,[nmrAP*nmrSetups,nmrUE]);
Shannon=zeros(nmrSetups,nmrUE);

for x = 1:nmrUE
    for y = 1:nmrSetups*nmrAP
        Shannon(y, x) = bc * log2(1 + conv_sinr(y, x));  % Agora `conv_sinr` é uma matriz 2D
    end
end

media=mean(sum(Shannon,2)); %Cálculo da média da sum-capacity

Shannon_ord=reshape(Shannon,1,[]);
%% Eficiência Espectral
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
