# 🛳️ Battaglia Navale 2.0 — Venezia, 1987 / 2025

Un gioco in QuickBASIC nato nel cuore degli anni '80, restaurato con cura e passione. Grafica ASCII, IA con memoria, griglie dinamiche e una Top Ten che premia l’efficienza. Ogni riga è un frammento di storia, ogni test una piccola poesia algoritmica.

## 🎮 Caratteristiche principali

- **Grafica testuale** in ASCII art, compatibile con CGA o superiore.
- **Griglia dinamica** da 8×8 a 20×20, con flotta adattiva.
- **IA con memoria**, inseguimento e marcatura del contorno.
- **Cursore controllato da frecce** per piazzamento e attacco.
- **Classifica Top Ten** con punteggio calcolato in base a tempo, efficienza e complessità.

## 🧠 Intelligenza artificiale

- Memorizza i colpi a segno (`ColpiInseguiti()`).
- Deduce l’orientamento della nave (`DeduciOrientamentoNave()`).
- Marca il contorno dopo l’affondamento (`MarcaContornoNave()`).

## ⚙️ Dinamicità della flotta

La dimensione della griglia (`XY`) determina:
- Numero di classi di nave (`Lunghezza`)
- Lunghezza per classe: `1 + Lunghezza - i`
- Quantità per classe: `CINT(i * XY / 10 - 1 / XY)`

Esempi:
- XY = 10 → 4 classi, 10 navi totali
- XY = 20 → 5 classi, 30 navi totali

## 📊 Classifica e punteggio

Il punteggio premia:
- Rapidità (`Secondi!`)
- Efficienza (`ColpiSprecati`)
- Complessità della griglia

Formula dettagliata e commenti tecnici in [`BN_tech.txt`](BN_tech.txt)

## 🧪 Test e benchmark

Cinque test automatici con output `.DAT` e screenshot:
- Piazzamento rapido
- Calcolo ingombri
- Collaudo punteggi
- Piazzamenti compatti
- Istogramma flotte

## 📁 File inclusi

| Tipo        | File                          |
|-------------|-------------------------------|
| Codice      | `BN2CD.BAS`                   |
| Documenti   | `README.md`, `BN_tech.txt`    |
| Test        | `BN2TEST1-5.BAS` + `.DAT`     |
| Screenshot  | `BN2-01.png` → `BN2-05.png`   |

## 🖥️ Requisiti

- QuickBASIC / QBX / VBDOS / DOSBox
- CGA o superiore
- Tastiera con frecce

---

> Questo progetto fa parte di un archivio vivente. Ogni file è un frammento di memoria, ogni algoritmo una riflessione sul tempo, sull’efficienza e sulla bellezza del codice.
