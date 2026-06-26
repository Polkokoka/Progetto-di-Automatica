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

cm      = 3;
cp      = 1e-5;
g       = 9.81;

s = tf('s');

%% Caricamento modello linearizzato fornito

load('carroponte_param')

% Stato del modello fornito:
% x = [s theta s_dot theta_dot]
%
% Uscita controllata:
% y_load = s + l*sin(theta) ~= s + l*theta

C_load = [1 l 0 0];
D_load = 0;

sys_load = ss(A, B, C_load, D_load);

G = minreal(tf(sys_load));

%% Stampa funzione di trasferimento
fprintf('\n--- Forma di Evans di G(s) ---\n')
G_zpk = zpk(G);
G_zpk

fprintf('\n--- Poli di G ---\n');
disp(pole(G))

fprintf('\n--- Zeri di G ---\n');
disp(zero(G))

[numG, denG] = tfdata(G, 'v');

fprintf('\n--- Numeratore G ---\n');
disp(numG)

fprintf('\n--- Denominatore G ---\n');
disp(denG)

%% Grafico Bode di G(s)

figure
bode(G)
grid on
title('Diagramma di Bode di G(s) = posizione carico / forza')

%% Grafico risposta al gradino di G(s)

figure
step(G)
grid on
title('Risposta al gradino di G(s)')
xlabel('time [s]')
ylabel('load position [m]')

%% Mappa poli-zeri

figure
pzmap(G)
grid on
title('Mappa poli-zeri di G(s)')