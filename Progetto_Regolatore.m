clear all
clc
close all

%% Parametri

l       = 0.229;
M       = 0.57;
m       = 0.119;
mtot    = M + m;

J       = 4.458e-4;
Jtot    = m*l^2 + J;

cm      = 3;            % attrito carrello
cp      = 1e-5;         % attrito pendolo

g = 9.81;

s = tf('s');

%% Caricamento modello linearizzato fornito

load('carroponte_param')

% Vettore di stato:
% x = [x theta x_dot theta_dot]

sys_carroponte_OL = ss(A, B, C, D);

%% Regolatore progettato

% Regolatore scelto:
% compensa parzialmente la dinamica oscillante del pendolo
% e introduce due poli reali per filtrare l'azione di controllo.

run("Cerca_Poli_R.m")
load("poli_R_ottimizzati.mat", "p1_best", "p2_best", "K");
R = K*(s^2 + 0.5803*s + 45)/((s + p1_best)*(s + p2_best));

%% Margini del regolatore progettato

C_load = [1 l 0 0];
D_load = 0;

G = minreal(tf(ss(A, B, C_load, D_load)));

L = minreal(R*G);
[~, Pm, ~, Wcp] = margin(L);

fprintf('\n--- Margini regolatore progettato ---\n');
fprintf('Pm = %.2f deg\n', Pm);
fprintf('Wcp = %.4f rad/s\n', Wcp);


%% Preparazione simulazione non lineare

t  = (0:0.001:15)';
x0 = [0 0*pi/180 0 0]';

% Tempo di applicazione dello step nel blocco Simulink
t_step = 0;

%% Simulazione non lineare

sim('sim_carroponte_CL_students')

%% Grandezze derivate

% Posizione assoluta del carico
load_pos = car + l*sin(pend);

% Oscillazione lineare del carico rispetto al carrello
load_osc = l*sin(pend);

%% Verifica requisiti

fprintf('\n--- Verifica requisiti modello non lineare ---\n');

fprintf('Massima posizione carico: %.4f m\n', max(load_pos));
fprintf('Limite massimo richiesto: 0.6800 m\n');

idx_load = find(load_pos >= 0.66, 1, 'first');

if ~isempty(idx_load)
    t_abs = t(idx_load);
    t_rel = t_abs - t_step;

    fprintf('Il carico raggiunge 0.66 m a t assoluto = %.4f s\n', t_abs);
    fprintf('Tempo dal comando = %.4f s\n', t_rel);
else
    fprintf('Il carico non raggiunge 0.66 m nella simulazione.\n');
end

fprintf('Massima oscillazione lineare rispetto al carrello: %.4f m\n', ...
        max(abs(load_osc)));

fprintf('Massima forza applicata: %.4f N\n', max(abs(F)));


%% Step response 

C_load = [1 l 0 0];
D_load = 0;

sys_load = ss(A, B, C_load, D_load);
G = tf(sys_load);

L = minreal(R*G);
T_cl = feedback(L, 1);

%% Verifica requisiti minimi della traccia sul modello linearizzato

% Requisiti della traccia
r = 0.66;
y_max_req = 0.68;
T_max = 1.8;

% Sovraelongazione massima ammessa
S_perc_max = 100*(y_max_req - r)/r;

% Smorzamento minimo equivalente
S = S_perc_max/100;
xi_min = -log(S)/sqrt(pi^2 + log(S)^2);

% Margine di fase minimo stimato
phi_m_min = 100*xi_min;

% Margini di L(s)
[Gm, Pm, Wcg, Wcp] = margin(L);

% Risposta al gradino del modello linearizzato
t_lin = 0:0.001:15;
[y_lin, t_lin] = step(r*T_cl, t_lin);
y_lin = squeeze(y_lin);

% Sovraelongazione percentuale effettiva
y_peak = max(y_lin);
S_perc = 100*(y_peak - r)/r;

fprintf('\n--- Verifica sovraelongazione carico linearizzato ---\n');

fprintf('Sovraelongazione massima ammessa: %.2f %%\n', S_perc_max);
fprintf('Sovraelongazione ottenuta:        %.2f %%\n', S_perc);

if S_perc <= S_perc_max
    fprintf('OK: sovraelongazione soddisfatta.\n');
else
    fprintf('NO: sovraelongazione eccessiva.\n');
end

%% Verifica del tempo di raggiungimento pos

idx = find(y_lin >= r, 1, 'first');

if ~isempty(idx)
    t_r_lin = t_lin(idx);
    fprintf('\nTempo raggiungimento %.2f m: %.4f s\n', r, t_r_lin);

    if t_r_lin <= T_max
        fprintf('OK: tempo di raggiungimento soddisfatto.\n');
    else
        fprintf('NO: tempo di raggiungimento troppo alto.\n');
    end
else
    fprintf('\nNO: il sistema linearizzato non raggiunge %.2f m.\n', r);
end

%% Grafici 
figure
step(0.66*T_cl, 0:0.001:15)
hold on
yline(0.66, 'g:', 'LineWidth', 1.2);
yline(0.68, 'r--', 'LineWidth', 1.2);
grid on
title('Step response modello linearizzato in anello chiuso')
xlabel('time [s]')
ylabel('load position [m]')
legend('step response', '0.66 m', '0.68 m', 'Location', 'best')



