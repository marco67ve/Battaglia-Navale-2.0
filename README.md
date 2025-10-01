# Battaglia Navale 2.0 (BN2CD) — Marco da Venezia, 1987

**Descrizione sommaria**  
Battaglia Navale 2.0 è un gioco in BASIC (file `BN2CD.BAS`) scritto in QuickBASIC. La grafica è in ASCII art (CGA o superiore consigliata). L'interfaccia usa il cursore gestito con i tasti freccia per piazzare le navi e per sparare.

## Caratteristiche principali
- Grafica testuale (ASCII art). Richiede CGA o superiore per un'aspetto ottimale.
- Griglie dinamiche: dimensioni selezionabili dall'utente tra **8×8** e **20×20** (anche su PC XT).
- Numero e lunghezza delle navi sono calcolati dinamicamente in funzione della dimensione della griglia.
- IA dotata di logiche di inseguimento (memoria dei colpi a segno) e marcatura del contorno delle navi.
- Cursore gestito con i tasti freccia per piazzare navi e puntare durante l'attacco.
- Classifica **Top Ten** gestita da file / routine interne con logica dedicata per il calcolo del punteggio.

## Requisiti
- QuickBASIC / QBX / VBDOS o ambiente compatibile come DOSBox.
- Videoadattatore CGA o superiore (ASCII art).
- Tastiera con tasti freccia disponibili.

## Come funziona la dinamicità di navi
- La variabile `XY` imposta la dimensione della griglia (es. 8..20).
- La variabile `Lunghezza` (nel main) è impostata così:
  - `IF XY > 10 THEN Lunghezza = 5 ELSE Lunghezza = 4`
  - Questo determina quante *classi di nave* ci sono: 4 classi per le griglie <11x11, 5 classi per griglie >10.
- La lunghezza di ciascuna nave nella classe `i` è:
  - `Navi(i).Lunghezza = 1 + Lunghezza - i`
  - (Quindi classi crescenti contengono navi più corte.)
- Il numero di navi per classe è calcolato con:
  - `Navi(i).Quante = CINT(i * XY / 10 - 1 / XY)`
- Esempi pratici:
  - Per **XY = 10** (Lunghezza = 4): classi lunghezze = 4,3,2,1 con quantità 1,2,3,4 (totale = 10 navi)
  - Per **XY = 20** (Lunghezza = 5): classi lunghezze = 5,4,3,2,1 con quantità 2,4,6,8,10 (totale = 30 navi)

## IA e logica d'attacco
- L'IA mantiene un array `ColpiInseguiti(1 TO 10)` con le coordinate dei colpi a segno non ancora affondati.
- Quando un colpo è a segno viene attivata la logica di inseguimento: il PC tenta di dedurre orientamento e continuare colpi adiacenti fino ad affondare la nave.
- Viene trattata anche la marcatura del contorno: dopo l'affondamento, la routine `MarcaContornoNave` segnala le caselle intorno alla nave per evitare tiri inutili.

## Controllo velocità e compatibilità
- La sub `TestPC cpu` controlla la compatibilità video; la sub MostraNaveTemporanea consente di piazzare le navi rapidamente anche con CPU lente (8088 a 4.77).
- Il gioco usa la BIOS data area e il timer di sistema (vedi routine specifiche nelle SUB).

## Classifica e punteggio
- Al termine della partita la routine `CalcolaPunteggio` valuta il risultato e `Classifica` aggiorna la Top Ten.
- La formula del punteggio è documentata in `BN_tech.txt` con esempi.

## File inclusi
- `BN2CD.BAS` (sorgente)
- `README.md` (questa pagina)
- `BN_tech.txt` (documentazione tecnica e commenti riga-per-riga)
-  Screenshot del gioco
   ```
   BN2-01.png
   BN2-02.png
   BN2-03.png
   BN2-04.png
   BN2-05.png
-  Test
   ```
   BN2TEST1.BAS (Test crono piazzamento navi)
   BN2TEST1.DAT (Risultati)
   BN2TEST1.png (Screenshot)
   BN2TEST2.BAS (Calcolo ingombri)
   BN2TEST2.DAT (Risultati)
   BN2TEST3.BAS (Collaudo punteggi)
   BN2TEST3.DAT (Risultati e grafico)
   BN2TEST3.PNG (Screenshot)
   BN2TEST4.BAS (Ipotesi di piazzamenti compatti)
   BN2TEST4.DAT (Risultati)
   BN2TEST5.BAS (Istogramma flotte compatte vs random)
   BN2TEST5.DAT (Risultati)

