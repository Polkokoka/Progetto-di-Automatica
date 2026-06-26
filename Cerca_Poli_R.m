clear all
clc
close all

%% Parametri

l = 0.229;
s = tf('s');

load('carroponte_param')

% Uscita controllata:
% y_load = x + l*theta
C_load = [1 l 0 0];
D_load = 0;

G = minreal(tf(ss(A, B, C_load, D_load)));

%% Requisiti

r = 0.66;
y_max_req = 0.68;
T_max = 1.8;

% Sovraelongazione massima ammessa
S_perc_max = 100*(y_max_req - r)/r;
S = S_perc_max/100;

% Smorzamento minimo dalla formula della sovraelongazione:
% S% = 100*exp(-xi*pi/sqrt(1-xi^2))
xi_min = -log(S)/sqrt(pi^2 + log(S)^2);

% Vincolo di rapidita' considerando lo smorzamento:
% T_ass ~= 5/(xi*wn)
wn_min = 5/(xi_min*T_max);

fprintf('\n--- Requisiti tradotti ---\n');
fprintf('Sovraelongazione massima ammessa = %.2f %%\n', S_perc_max);
fprintf('xi_min = %.4f\n', xi_min);
fprintf('wn_min = %.4f rad/s\n', wn_min);

%% Struttura del regolatore

K = 35;

% Griglia di ricerca per i due poli
p1_vec = 5:1:30;
p2_vec = 20:1:80;

soluzioni = [];

%% Ricerca

for p1 = p1_vec
    for p2 = p2_vec

        if p2 <= p1
            continue
        end

        R = K*(s^2 + 0.5803*s + 45)/((s + p1)*(s + p2));

        L = minreal(R*G);
        T_cl = feedback(L, 1);

        if ~isstable(T_cl)
            continue
        end

        [~, Pm, ~, Wcp] = margin(L);

        if isnan(Pm) || isnan(Wcp)
            continue
        end

        % Risposta al gradino
        t_test = 0:0.001:15;
        [y, t_out] = step(r*T_cl, t_test);
        y = squeeze(y);

        y_peak = max(y);
        S_perc = 100*(y_peak - r)/r;

        idx = find(y >= r, 1, 'first');

        if isempty(idx)
            t_r = NaN;
        else
            t_r = t_out(idx);
        end

        % Vincoli diretti della traccia
        ok_tempo = ~isnan(t_r) && t_r <= T_max;
        ok_sovr = S_perc <= S_perc_max;

        if ok_tempo && ok_sovr
            soluzioni = [soluzioni;
                         p1, p2, Pm, Wcp, S_perc, y_peak, t_r];
        end

    end
end

%% Scelta della soluzione migliore

if isempty(soluzioni)
    error('Nessuna coppia p1, p2 soddisfa tempo e sovraelongazione.');
end

% Priorita':
% 1) margine di fase massimo
% 2) tempo di raggiungimento minimo
soluzioni_ord = sortrows(soluzioni, [-3 7]);

scelta = soluzioni_ord(1,:);

p1_best = scelta(1);
p2_best = scelta(2);
Pm_best = scelta(3);
Wcp_best = scelta(4);
S_perc_best = scelta(5);
y_peak_best = scelta(6);
t_r_best = scelta(7);

R_best = minreal(K*(s^2 + 0.5803*s + 45)/((s + p1_best)*(s + p2_best)));
L_best = minreal(R_best*G);
T_best = feedback(L_best, 1);

[numR_best, denR_best] = tfdata(R_best, 'v');

%% Stampa risultati

fprintf('\n--- Soluzione migliore trovata ---\n');
fprintf('K = %.2f\n', K);
fprintf('p1 = %.2f\n', p1_best);
fprintf('p2 = %.2f\n', p2_best);
fprintf('Pm = %.2f deg\n', Pm_best);
fprintf('Wcp = %.4f rad/s\n', Wcp_best);
fprintf('Sovraelongazione = %.2f %%\n', S_perc_best);
fprintf('Picco y = %.4f m\n', y_peak_best);
fprintf('Tempo raggiungimento = %.4f s\n', t_r_best);

fprintf('\nRegolatore trovato:\n');
R_best

fprintf('\nNumeratore R:\n');
disp(numR_best)

fprintf('Denominatore R:\n');
disp(denR_best)

%% Salvataggio

save('poli_R_ottimizzati.mat', 'p1_best', 'p2_best', 'K');

fprintf('\nRisultati salvati in poli_R_ottimizzati.mat\n');