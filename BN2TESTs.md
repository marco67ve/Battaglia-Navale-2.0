# 🧪 BN2TESTS — Collaudo e benchmark per BN2CD.BAS

Questa raccolta di test automatici accompagna il gioco "Battaglia Navale 2.0" nella sua fase di verifica e documentazione. Ogni test è pensato per esplorare un aspetto specifico del motore di gioco, con output `.DAT` leggibili e screenshot associati.

I test sono scritti in QuickBASIC e si eseguono in ambienti compatibili (QB / QBX / VBDOS / DOSBox).

---

## 📌 BN2TEST1.BAS — Piazzamento rapido

- Simula il piazzamento automatico di navi su griglie di varie dimensioni.
- Verifica la velocità e la correttezza del posizionamento.
- Output: `BN2TEST1.DAT` con coordinate e tempi.
- Screenshot: `BN2-01.png`

📝 Note: utile per testare l’efficienza dell’algoritmo di piazzamento e la gestione degli ingombri.

---

## 📌 BN2TEST2.BAS — Calcolo ingombri

- Analizza la distribuzione spaziale delle navi.
- Calcola l’area occupata e la densità relativa.
- Output: `BN2TEST2.DAT` con statistiche per classe.
- Screenshot: `BN2-02.png`

📝 Note: evidenzia la proporzionalità tra griglia e flotta, utile per bilanciamento.

---

## 📌 BN2TEST3.BAS — Collaudo punteggi

- Simula partite con parametri variabili (tempo, colpi, dimensione).
- Calcola il punteggio secondo la formula ufficiale.
- Output: `BN2TEST3.DAT` con punteggi e ranking simulati.
- Screenshot: `BN2-03.png`

📝 Note: verifica la correttezza della classifica e la sensibilità della formula.

---

## 📌 BN2TEST4.BAS — Piazzamenti compatti

- Cerca configurazioni di flotta con minimo ingombro.
- Verifica la validità e l’assenza di sovrapposizioni.
- Output: `BN2TEST4.DAT` con layout e coordinate.
- Screenshot: `BN2-04.png`

📝 Note: utile per testare la robustezza del controllo di collisione.

---

## 📌 BN2TEST5.BAS — Istogramma flotte

- Genera istogrammi ASCII della composizione della flotta.
- Visualizza quantità e lunghezza per classe.
- Output: `BN2TEST5.DAT` con grafico testuale.
- Screenshot: `BN2-05.png`

📝 Note: strumento didattico per comprendere la logica della flotta dinamica.

---

## 🧭 Conclusione

Questi test non sono solo strumenti di verifica: sono piccole finestre sul cuore del motore di gioco. Ogni `.DAT` racconta una storia, ogni screenshot è una fotografia di un algoritmo in azione.

> Se il codice è un diario, i test sono le sue pagine di laboratorio.
