Qui ho caricato i file utilizzati nella redazione del terzo punto del progetto di automatica:

[Progetto_Regolatore](Progetto_Regolatore): questo file costruisce il regolatore eseguendo [Cerca_Poli_R](Cerca_Poli_R), poi imposta il sistema in anello chiuso simulando il sistema non lineare e poi il sistema lineare. Stampa in Command Window i parametri ottenuti e fa controlli sul rispetto dei requisiti in approssimazione di poli dominanti nel modello lineare e sui requisiti della consegna dell'esercizio nel caso reale;

[Cerca_Poli_R](Cerca_Poli_R): file di supporto che viene automaticamente eseguito runnando [Progetto_Regolatore](Progetto_Regolatore), per trovare il guadagno e i due poli della R fittando i requisiti con i parametri settati nel file stesso;

[Estrai_G](Estrai_G): funzione molto semplice che serve solo a calcolare G a partire da []() e ne fornisce diagramma di Bode, mappa poli e zeri e in Command Window anche la forma di Evans;

[carroponte_inizializzazione_solution](carroponte_inizializzazione_solution): file fornito con la traccia dell'esercizio, serve per verificare che la R sia adatta e rispetti tutti i parametri:

[sim_carroponte_OL](sim_carroponte_OL): Serve per fare la simulazione del modello in anello aperto;

