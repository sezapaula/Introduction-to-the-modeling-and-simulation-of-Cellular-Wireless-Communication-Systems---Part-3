% Número de amostras
n = 100000;

% Passo 1: Gerar dois vetores longos de números aleatórios normais
x1 = randn(n, 1); % Números normais com média 0 e variância 1
x2 = randn(n, 1); 

% Passo 2: Gerar números aleatórios de Rayleigh
r = sqrt(x1.^2 + x2.^2);

% Passo 3: Plotar um histograma de r
figure;
histogram(r, 'Normalization', 'pdf', 'BinWidth', 0.2);
hold on;

% Passo 4: Adicionar a curva de densidade da distribuição de Rayleigh
sigma = 1; % parâmetro da distribuição de Rayleigh
x = 0:0.01:max(r); % valores x para a curva
pdf_rayleigh = (x/sigma^2) .* exp(-x.^2/(2*sigma^2)); % PDF de Rayleigh
plot(x, pdf_rayleigh, 'LineWidth', 2);

% Passo 5: Indicar com asteriscos vermelhos
% Valores esperados ao longo da PDF
expected_values = 0:0.01:max(r); % Espalhar os valores esperados
pdf_expected = (expected_values/sigma^2) .* exp(-expected_values.^2/(2*sigma^2));
plot(expected_values, pdf_expected, 'r*', 'MarkerSize', 4, 'Color', 'red'); % Asteriscos menores para melhor visualização
%legend( 'Expected values', 'Location', 'Best');

% Configurar o gráfico
title('Histogram');
xlabel('Values');
ylabel('Density');
grid on;
%legend( 'Expected values', 'Location', 'Best');


% Adicionar a legenda apenas para a terceira curva (valores esperados)
legend('Generated Rayleigh random numbers','Corresponding theoretical', 'Location', 'Best'); 
print(gcf, 'fig3.eps', '-depsc');
hold off;
