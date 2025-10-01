' Battaglia navale 2.01
' BN2CD.BAS
' Battaglia Navale a Casella Doppia
' PD 1987 by Marco da Venezia

DEFINT A-Z

' Gestione interfaccia
DECLARE SUB Interfaccia ()
DECLARE SUB CLSrow (riga, col1, col2, cursore, testo, sfondo, messaggio$)
DECLARE SUB Cornice (r1, r2, c1, c2, testo, sfondo, car, titolo$)
DECLARE SUB DisegnaGriglie ()
DECLARE SUB Fine (Esc)

' Visualizzazione griglie
DECLARE SUB MostraGrigliaPlayer (cx, cy, Direzione, Lunghezza)
DECLARE SUB MostraGrigliaColpiPC ()
DECLARE SUB Z.spiaGrigliaPC () ' *** Per collaudo

' Gestione piazzamento navi
DECLARE SUB PiazzaNave (Flag)
DECLARE SUB PiazzaNavePC (Lunghezza)
DECLARE SUB PiazzaNavePlayer (Lunghezza)
DECLARE FUNCTION TentaPiazzaNave (x, y, Direzione, Lunghezza, Flag)
DECLARE FUNCTION TentaPiazzaNavePC (x, y, Direzione, Lunghezza)
DECLARE FUNCTION TentaPiazzaNavePlayer (x, y, Direzione, Lunghezza)
DECLARE SUB MarcaContornoNave (x, y, Flag)
DECLARE SUB MarcaContornoNavePC (x, y)
DECLARE SUB MarcaContornoNavePlayer (x, y)
DECLARE SUB MostraNaveTemporanea (cx, cy, Direzione, Lunghezza, evidenzia)

' Gestione turni di gioco
DECLARE SUB FaseAttaccoPC ()
DECLARE SUB FaseAttaccoPlayer ()

' Controlli sullo stato delle navi
DECLARE SUB ProvaColpo (nx, ny, trovato)
DECLARE FUNCTION DeduciOrientamentoNave ()
DECLARE FUNCTION NaveAffondata (x, y, Flag)
DECLARE FUNCTION NaveAffondataPC (x, y)
DECLARE FUNCTION NaveAffondataPlayer (x, y)

' Controlli sullo stato della partita
DECLARE FUNCTION FineGriglia (Griglia())
DECLARE FUNCTION FineGrigliaPC ()
DECLARE FUNCTION FineGrigliaPlayer ()

' Calcolo dei punteggi e classifica
DECLARE SUB CalcolaPunteggio ()
DECLARE SUB Classifica (Punteggio)
COMMON SHARED Secondi!, ColpiSprecati

' Controllo input utente
DECLARE SUB EditLine (edit$, Caratteri, car1, car2)

' Controllo XT
DECLARE SUB TestPC ()

' INIZIALIZZAZIONE

TestPC ' Controlla CGA

Interfaccia ' Disegna l'interfaccia di gioco

' Richiesta dimensione griglia
CLSrow 24, 3, 79, 1, 14, 1, "Scegli la griglia (8-20): "
DIM SHARED XY!
EditLine edit$, 2, 48, 57
XY! = VAL(edit$)
IF XY! < 8 OR XY! > 20 THEN XY! = 10 ' Default

' Array griglie (max 20x20)
REDIM SHARED GrigliaNaviPC(1 TO 20, 1 TO 20)
DIM SHARED GrigliaNaviPlayer(1 TO 20, 1 TO 20)

' Dichiarazione variabili e costanti
DIM SHARED r1naviradar, c1navi, c2navi, c1radar
DIM SHARED ColpiInseguiti(1 TO 10) ' Coordinate (x,y) dei colpi a segno non ancora affondati
DIM SHARED NumColpiInseguiti ' Contatore di coppie (x,y) attive
CONST Pausa$ = " - Premi un tasto per continuare..."

Cornice 1, 25, 1, 79, 7, 1, 32, "" ' Cancella intro
DisegnaGriglie

' Definizione struttura nave
TYPE TipoNave
	Lunghezza AS INTEGER   ' dimensione della nave
	Quante AS INTEGER      ' numero di navi
END TYPE

' Array contenente le navi
DIM SHARED Navi(5) AS TipoNave
DIM SHARED Lunghezza

' Lunghezza nave secondo la griglia
IF XY! > 10 THEN Lunghezza = 5 ELSE Lunghezza = 4

Cornice r1naviradar, r1naviradar + Lunghezza + 1, c2navi + 3, c1radar - 3, 0, 3, 32, " Navi "

' Numero di navi per ciascuna lunghezza
FOR i = 1 TO Lunghezza
	Navi(i).Lunghezza = 1 + Lunghezza - i
	Navi(i).Quante = CINT(i * XY! / 10 - 1 / XY!)
	LOCATE , c2navi + 3 + 2, 0: PRINT USING "## da #"; Navi(i).Quante; Navi(i).Lunghezza
NEXT

RANDOMIZE TIMER

DIM SHARED Fallito

' Piazzamento navi PC
DO
		Fallito = 0
		PiazzaNave 1
LOOP WHILE Fallito = -1

' Piazzamento navi Player
PiazzaNave 0

' Cancella area info piazzamento
COLOR 7, 1
FOR i = 3 TO 7
	LOCATE r1naviradar + Lunghezza + i, c2navi + 3: PRINT SPACE$(12);
NEXT

' Effetti sonori
CONST playVinto$ = "o2l8c8f8a8o3c4o2a8o3l4c"
CONST playPerso$ = "o2l8cccd#ddcco1bo2l4c"
CONST playAcqua$ = "o1l32ab"
CONST playColpito$ = "o2l32ab"
CONST playAffondato$ = "o3l32ab"
CONST playSprecato$ = "o0l32aaa"
CONST playOk = "o2mbc64"
CONST playErrato$ = "o0l32aba"

' CICLO DI GIOCO
DO
	' Turno Player
	CALL FaseAttaccoPlayer
	IF FineGrigliaPC THEN
		CLSrow 24, 3, 79, 0, 14, 1, "Hai vinto!" + Pausa$
		PLAY playVinto$
		EXIT DO
	END IF

	IF FineGrigliaPlayer THEN
		CLSrow 24, 3, 79, 0, 14, 1, "Hai perso!" + Pausa$
		PLAY playPerso$
		EXIT DO
	END IF

	' Turno PC
	CALL FaseAttaccoPC
	IF FineGrigliaPC THEN
		CLSrow 24, 3, 79, 0, 14, 1, "Hai vinto!" + Pausa$
		PLAY playVinto$
		EXIT DO
	END IF
	IF FineGrigliaPlayer THEN
		CLSrow 24, 3, 79, 0, 14, 1, "Hai perso!" + Pausa$
		PLAY playPerso$
		EXIT DO
	END IF
LOOP

k$ = INPUT$(1)
CalcolaPunteggio

Fine 0

SUB CalcolaPunteggio
	FOR x = 1 TO XY!
		FOR y = 1 TO XY!
			PuntiG = PuntiG + GrigliaNaviPlayer(x, y)
			PuntiPC = PuntiPC - GrigliaNaviPC(x, y)
		NEXT
	NEXT
	Punteggio = 10 * (PuntiG + PuntiPC + XY! ^ 2 - ColpiSprecati) - Secondi!
	Classifica Punteggio
END SUB

SUB Classifica (Punteggio)

	DIM TopTen$(10)

	Cornice 9, 22, 25, 55, 15, 4, 32, " CLASSIFICA "

	OPEN "BN2.SCO" FOR APPEND AS #1: CLOSE #1
	OPEN "BN2.SCO" FOR INPUT AS #1
	WHILE NOT EOF(1)
		n = n + 1
		LINE INPUT #1, TopTen$(n)
		LOCATE 10 + n, 28: PRINT USING "## - "; n;
		PRINT TopTen$(n)
	WEND
	CLOSE #1

	IF Punteggio > VAL(TopTen$(10)) THEN
		CLSrow 24, 3, 79, 1, 14, 1, "Nuovo Record! Inserisci il tuo nome: "
		EditLine edit$, 15, 32, 127
		TopTen$(10) = LTRIM$(STR$(Punteggio)) + " * " + edit$
		FOR i = 1 TO 9
			FOR j = 1 TO 10 - i
				IF VAL(TopTen$(j)) < VAL(TopTen$(j + 1)) THEN
					SWAP TopTen$(j), TopTen$(j + 1)
				END IF
			NEXT j
		NEXT i
		Cornice 9, 22, 25, 55, 0, 2, 32, " CLASSIFICA "
		OPEN "BN2.SCO" FOR OUTPUT AS #1
		FOR n = 1 TO 10
			PRINT #1, TopTen$(n)
			LOCATE 10 + n, 28: PRINT USING "## - "; n;
			PRINT TopTen$(n)
		NEXT
		CLOSE #1
	END IF
END SUB

SUB CLSrow (riga, col1, col2, cursore, testo, sfondo, messaggio$)
	COLOR testo, sfondo
	LOCATE riga, col1, cursore: PRINT SPACE$(col2 - col1);
	LOCATE riga, 40 - LEN(messaggio$) \ 2: PRINT messaggio$;
END SUB

SUB Cornice (r1, r2, c1, c2, testo, sfondo, car, titolo$)
	COLOR testo, sfondo
	FOR i = r1 TO r2
		car$ = CHR$(car): vs$ = CHR$(186): vd$ = vs$
		SELECT CASE i
			CASE r1
				car$ = CHR$(205): vs$ = CHR$(201): vd$ = CHR$(187)
			CASE r2
				car$ = CHR$(205): vs$ = CHR$(200): vd$ = CHR$(188)
		END SELECT
		LOCATE i, c1, 0: PRINT vs$ + STRING$(c2 - c1, car$) + vd$;
	NEXT
	LOCATE r1, 1 + c1 + (c2 - c1 - LEN(titolo$)) \ 2: PRINT titolo$
END SUB

FUNCTION DeduciOrientamentoNave

	IF NumColpiInseguiti < 2 THEN
		DeduciOrientamentoNave = -1 ' Dati insuff.
		EXIT FUNCTION
	END IF

	x1 = ColpiInseguiti(1)
	y1 = ColpiInseguiti(2)
	x2 = ColpiInseguiti(3)
	y2 = ColpiInseguiti(4)

	IF x1 = x2 THEN
		DeduciOrientamentoNave = 1 ' Verticale
	ELSEIF y1 = y2 THEN
		DeduciOrientamentoNave = 0 ' Orizzontale
	ELSE
		DeduciOrientamentoNave = -1 ' Dati insuff.
	END IF

END FUNCTION

SUB DisegnaGriglie

	r1naviradar = 12 - XY! / 2
	r2naviradar = 13 + XY! / 2
	c1navi = 40 - (16 + 3 * XY!) \ 2
	c2navi = c1navi + 2 * XY!
	c1radar = c2navi + 16
	c2radar = c1radar + XY!

	Cornice r1naviradar, r2naviradar, c1navi, c2navi, 0, 7, 32, " TU "
	Cornice r1naviradar, r2naviradar, c1radar, c2radar, 0, 7, 254, " PC "

	FOR i = 1 TO XY!
		c$ = c$ + "[]"
	NEXT
	FOR i = 1 TO XY!
		LOCATE r1naviradar + i, c1navi + 1
		PRINT c$
	NEXT

END SUB

SUB EditLine (edit$, Caratteri, car1, car2)
	edit$ = ""
	DO
		k$ = INKEY$
		IF k$ = CHR$(13) THEN EXIT DO
		IF k$ = CHR$(8) THEN
			IF LEN(edit$) THEN
				edit$ = LEFT$(edit$, LEN(edit$) - 1)
				LOCATE , POS(0) - 1: PRINT CHR$(32);
				LOCATE , POS(0) - 1
			END IF
		END IF
		IF LEN(edit$) < Caratteri AND k$ >= CHR$(car1) AND k$ <= CHR$(car2) THEN
			edit$ = edit$ + k$
			PRINT k$;
		END IF
	LOOP
END SUB

SUB FaseAttaccoPC
	DIM x, y, nx, ny, trovato, orientamento
	trovato = 0

	' Inseguendo, prova attorno ai colpi noti
	IF NumColpiInseguiti > 0 THEN
		orientamento = DeduciOrientamentoNave

		FOR i = 1 TO NumColpiInseguiti
			x = ColpiInseguiti(i * 2 - 1)
			y = ColpiInseguiti(i * 2)

			IF orientamento = 0 OR orientamento = 1 THEN
				' Orizzontale o verticale: jitter per invertire l'ordine dei tentativi
				IF RND < .5 THEN
					' Primo tentativo diretto
					IF orientamento = 0 THEN
						nx = x - 1: ny = y: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
						nx = x + 1: ny = y: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					ELSE
						nx = x: ny = y - 1: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
						nx = x: ny = y + 1: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					END IF
				ELSE
					' Ordine invertito
					IF orientamento = 0 THEN
						nx = x + 1: ny = y: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
						nx = x - 1: ny = y: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					ELSE
						nx = x: ny = y + 1: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
						nx = x: ny = y - 1: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					END IF
				END IF

			ELSE
				' Orientamento incerto: prova a caso orizzontale o verticale
				IF RND < .5 THEN
					' Orizzontale
					nx = x - 1: ny = y: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					nx = x + 1: ny = y: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					nx = x: ny = y - 1: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					nx = x: ny = y + 1: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
				ELSE
					' Verticale
					nx = x: ny = y - 1: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					nx = x: ny = y + 1: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					nx = x - 1: ny = y: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
					nx = x + 1: ny = y: CALL ProvaColpo(nx, ny, trovato): IF trovato THEN EXIT FOR
				END IF
			END IF

			IF trovato THEN EXIT FOR
		NEXT
	END IF

	' Se non ha sparato in inseguimento, va di random
	IF trovato = 0 THEN
		DO
			x = INT(RND * XY!) + 1
			y = INT(RND * XY!) + 1

			' jitter di fortuna
			IF GrigliaNaviPlayer(x, y) = 0 THEN
				IF RND < .5 THEN ' imposta < 0 per no fortuna
					x = INT(RND * XY!) + 1
					y = INT(RND * XY!) + 1
					' BEEP ' per collaudo
				END IF
			END IF

			CALL ProvaColpo(x, y, trovato)
		LOOP WHILE trovato = 0
	END IF
   
	k$ = INPUT$(1)
	MostraGrigliaColpiPC

END SUB

SUB FaseAttaccoPlayer
	DIM x, y, tasto, tasto$
	x = CINT(XY! / 2): y = CINT(XY! / 2)
	DO
		CLSrow 24, 3, 79, 0, 14, 1, "Muovi con i tasti freccia e spara con Invio"
		FOR j = 1 TO XY!
			LOCATE j + r1naviradar, 1 + c1radar
			FOR i = 1 TO XY!
				IF i = x AND j = y THEN
					IF GrigliaNaviPC(i, j) = -2 THEN COLOR 28, 0 ELSE COLOR 31, 0
					PRINT "+";
				ELSEIF GrigliaNaviPC(i, j) = -1 THEN
					COLOR 0, 7: PRINT "~";
				ELSEIF GrigliaNaviPC(i, j) = -2 THEN
					COLOR 12, 0: PRINT "X";
				ELSE
					COLOR 0, 7: PRINT CHR$(254);
				END IF
			NEXT
		NEXT
		t1! = TIMER
		DO
			tasto$ = INKEY$
			IF LEN(tasto$) = 2 THEN tasto = ASC(RIGHT$(tasto$, 1))
			IF LEN(tasto$) = 1 THEN tasto = ASC(tasto$)
		LOOP WHILE tasto$ = ""
		SELECT CASE tasto
			CASE 72: IF y > 1 THEN y = y - 1
			CASE 80: IF y < XY! THEN y = y + 1
			CASE 75: IF x > 1 THEN x = x - 1
			CASE 77: IF x < XY! THEN x = x + 1
			CASE 13, 32
				LOCATE y + r1naviradar, x + c1radar
				IF GrigliaNaviPC(x, y) > 0 THEN
					GrigliaNaviPC(x, y) = -2
					COLOR 28, 0: PRINT "X";
					IF NaveAffondataPC(x, y) THEN
						MarcaContornoNavePC x, y
						CLSrow 24, 3, 79, 0, 28, 0, "Colpito e affondato!" + Pausa$
						PLAY playAffondato$
					ELSE
						CLSrow 24, 3, 79, 0, 28, 0, "Colpito!" + Pausa$
						PLAY playColpito$
					END IF
				ELSEIF GrigliaNaviPC(x, y) = 0 THEN
					GrigliaNaviPC(x, y) = -1
					COLOR 16, 7: PRINT "~";
					CLSrow 24, 3, 79, 0, 25, 0, "Acqua!" + Pausa$
					PLAY playAcqua$
				ELSE
					ColpiSprecati = ColpiSprecati + 1
					CLSrow 24, 3, 79, 0, 23, 0, "Sprecato!" + Pausa$
					PLAY playSprecato$
				END IF
				IF t1! < TIMER THEN
					Secondi! = Secondi! + INT(TIMER - t1!)
				ELSE
					Secondi! = Secondi! + 1 ' fix/bonus mezzanotte
				END IF
				k$ = INPUT$(1)
				EXIT DO
			CASE 255
				CALL Z.spiaGrigliaPC ' Visualizza griglia PC per collaudo
				SLEEP
			CASE 27: Fine 1
		END SELECT
	LOOP
END SUB

SUB Fine (Esc)
	IF Esc THEN
		CLSrow 24, 3, 79, 0, 30, 0, "Vuoi uscire? (S/N)"
		k$ = INPUT$(1)
		IF UCASE$(k$) <> "S" THEN EXIT SUB
	ELSE
		CLSrow 24, 3, 79, 1, 15, 1, "Giochi ancora? (S/N)"
		k$ = INPUT$(1)
		IF UCASE$(k$) <> "N" THEN RUN
	END IF
	COLOR 7, 0
	LOCATE , , 1
	CLS
	END
END SUB

FUNCTION FineGriglia (Griglia())
	FOR x = 1 TO XY!
		FOR y = 1 TO XY!
			IF Griglia(x, y) >= 1 AND Griglia(x, y) <= 5 THEN
				FineGriglia = 0
				EXIT FUNCTION
			END IF
		NEXT y
	NEXT x
	FineGriglia = -1
END FUNCTION

FUNCTION FineGrigliaPC
	FineGrigliaPC = FineGriglia(GrigliaNaviPC())
END FUNCTION

FUNCTION FineGrigliaPlayer
	FineGrigliaPlayer = FineGriglia(GrigliaNaviPlayer())
END FUNCTION

SUB Interfaccia
	Cornice 1, 25, 1, 79, 15, 1, 32, ""
	Classifica 0
	COLOR 3, 1
	LOCATE 3, 7: PRINT "ллл   лл  ллл ллл  лл   лл  л   л  лл     лл   лл  л  л  лл  л   ллл"
	LOCATE , 7:  PRINT "л  л л  л  л   л  л  л л    л   л л  л   л  л л  л л  л л  л л   л"
	LOCATE , 7:  PRINT "ллл  лллл  л   л  лллл л лл л   л лллл   л  л лллл л  л лллл л   ллн"
	LOCATE , 7:  PRINT "л  л л  л  л   л  л  л л  л л   л л  л   л  л л  л л  л л  л л   л"
	LOCATE , 7:  PRINT "ллл  л  л  л   л  л  л  лл  ллл л л  л   л  л л  л  лл  л  л ллл ллл"
	CLSrow 24, 3, 79, 0, 30, 1, " - Premi un tasto per giocare -"
	WHILE INKEY$ = ""
		c = c + 1
		IF c = 7 THEN c = 1
		PALETTE 3, 8 + c
		SLEEP (1)
	WEND
	PALETTE
END SUB

SUB MarcaContornoNave (x, y, Flag)
	
	DIM Vis(1 TO 20, 1 TO 20)
	DIM Qx(1 TO 400), Qy(1 TO 400)
	DIM sx(1 TO 400), sy(1 TO 400)
	DIM prua, poppa, nCelle, cx, cy, tx, ty, t, k, dx, dy

	prua = 1
	poppa = 0
	nCelle = 0

	' Assegna la griglia in base al Flag e controlla cella iniziale
	IF Flag = 1 THEN
		IF GrigliaNaviPC(x, y) <> -2 THEN EXIT SUB
	ELSE
		IF GrigliaNaviPlayer(x, y) <> -2 THEN EXIT SUB
	END IF

	' Enqueue di partenza
	poppa = poppa + 1
	Qx(poppa) = x
	Qy(poppa) = y
	Vis(x, y) = -1

	' Flood-fill 4-neighbors
	DO WHILE prua <= poppa
		cx = Qx(prua): cy = Qy(prua)
		prua = prua + 1
		nCelle = nCelle + 1
		sx(nCelle) = cx
		sy(nCelle) = cy

		FOR t = 0 TO 3
			SELECT CASE t
				CASE 0: tx = cx - 1: ty = cy
				CASE 1: tx = cx + 1: ty = cy
				CASE 2: tx = cx: ty = cy - 1
				CASE 3: tx = cx: ty = cy + 1
			END SELECT

			IF tx >= 1 AND tx <= XY! AND ty >= 1 AND ty <= XY! THEN
				IF Flag = 1 THEN
					IF Vis(tx, ty) = 0 AND GrigliaNaviPC(tx, ty) = -2 THEN
						Vis(tx, ty) = -1
						poppa = poppa + 1: Qx(poppa) = tx: Qy(poppa) = ty
					END IF
				ELSE
					IF Vis(tx, ty) = 0 AND GrigliaNaviPlayer(tx, ty) = -2 THEN
						Vis(tx, ty) = -1
						poppa = poppa + 1: Qx(poppa) = tx: Qy(poppa) = ty
					END IF
				END IF
			END IF
		NEXT t
	LOOP

	' Marca contorno 8-neighbors
	FOR k = 1 TO nCelle
		cx = sx(k): cy = sy(k)
		FOR dx = -1 TO 1
			FOR dy = -1 TO 1
				tx = cx + dx: ty = cy + dy
				IF tx >= 1 AND tx <= XY! AND ty >= 1 AND ty <= XY! THEN
					IF Flag = 1 THEN
						IF GrigliaNaviPC(tx, ty) = 0 THEN GrigliaNaviPC(tx, ty) = -1
					ELSE
						IF GrigliaNaviPlayer(tx, ty) = 0 THEN GrigliaNaviPlayer(tx, ty) = -1
					END IF
				END IF
			NEXT dy
		NEXT dx
	NEXT k
END SUB

SUB MarcaContornoNavePC (x, y)
	MarcaContornoNave x, y, 1
END SUB

SUB MarcaContornoNavePlayer (x, y)
	MarcaContornoNave x, y, 0
END SUB

SUB MostraGrigliaColpiPC
	LOCATE r1naviradar + 1, c1navi + 1, 0
	FOR y = 1 TO XY!
		FOR x = 1 TO XY!
			LOCATE r1naviradar + y, c1navi - 1 + 2 * x
			IF GrigliaNaviPlayer(x, y) = 0 THEN
				COLOR 0, 7: PRINT "[]";
			ELSEIF GrigliaNaviPlayer(x, y) = -1 THEN
				COLOR 1, 7: PRINT "()";
			ELSEIF GrigliaNaviPlayer(x, y) = -2 THEN
				COLOR 12, 0: PRINT "<>";
			ELSE
				COLOR GrigliaNaviPlayer(x, y): PRINT CHR$(219) + CHR$(219);
			END IF
		NEXT
	NEXT
	COLOR 0, 7
END SUB

SUB MostraGrigliaPlayer (cx, cy, Direzione, Lunghezza)
	' Piazzamento navi
	FOR y = 1 TO XY!
		FOR x = 1 TO XY!
			evidenzia = 0
			' Controlla se la cella e' sotto il cursore/nave in piazzamento
			FOR i = 0 TO Lunghezza - 1
				IF Direzione = 0 AND x = cx + i AND y = cy THEN evidenzia = 1
				IF Direzione = 1 AND x = cx AND y = cy + i THEN evidenzia = 1
			NEXT
			' Determina il carattere da mostrare
			IF GrigliaNaviPlayer(x, y) = 0 THEN c$ = "[]" ELSE c$ = CHR$(219) + CHR$(219)
			fg = GrigliaNaviPlayer(x, y)
			LOCATE r1naviradar + y, c1navi - 1 + 2 * x, 0
			IF evidenzia THEN
				' Evidenzia senza cancellare il carattere originale
				COLOR fg + 24, 0  ' oppure , 6
			ELSE
				COLOR fg, 7
			END IF
			PRINT c$;
		NEXT
	NEXT
	COLOR 0, 7
END SUB

SUB MostraNaveTemporanea (cx, cy, Direzione, Lunghezza, evidenzia)
	FOR i = 0 TO Lunghezza - 1
		IF Direzione = 0 THEN
			x = cx + i: y = cy
		ELSE
			x = cx: y = cy + i
		END IF
		IF GrigliaNaviPlayer(x, y) = 0 THEN c$ = "[]" ELSE c$ = CHR$(219) + CHR$(219)
		fg = GrigliaNaviPlayer(x, y)
		LOCATE r1naviradar + y, c1navi - 1 + 2 * x, 0
		IF evidenzia THEN
			COLOR fg + 24, 0 ' oppure ,6
		ELSE
			COLOR fg, 7
		END IF
		PRINT c$;
	NEXT
	COLOR 0, 7
END SUB

FUNCTION NaveAffondata (x, y, Flag)

	DIM oriz, vert, i, j
	oriz = 0: vert = 0

	' Controllo vicini
	IF x > 1 THEN
		IF (Flag = 1 AND GrigliaNaviPC(x - 1, y) = -2) OR (Flag = 0 AND GrigliaNaviPlayer(x - 1, y) = -2) THEN oriz = -1

		IF (Flag = 1 AND GrigliaNaviPC(x - 1, y) >= 1) OR (Flag = 0 AND GrigliaNaviPlayer(x - 1, y) >= 1) THEN NaveAffondata = 0: EXIT FUNCTION
	END IF

	IF x < XY! THEN
		IF (Flag = 1 AND GrigliaNaviPC(x + 1, y) = -2) OR (Flag = 0 AND GrigliaNaviPlayer(x + 1, y) = -2) THEN oriz = -1

		IF (Flag = 1 AND GrigliaNaviPC(x + 1, y) >= 1) OR (Flag = 0 AND GrigliaNaviPlayer(x + 1, y) >= 1) THEN NaveAffondata = 0: EXIT FUNCTION
	END IF

	IF y > 1 THEN
		IF (Flag = 1 AND GrigliaNaviPC(x, y - 1) = -2) OR (Flag = 0 AND GrigliaNaviPlayer(x, y - 1) = -2) THEN vert = -1

		IF (Flag = 1 AND GrigliaNaviPC(x, y - 1) >= 1) OR (Flag = 0 AND GrigliaNaviPlayer(x, y - 1) >= 1) THEN NaveAffondata = 0: EXIT FUNCTION
	END IF

	IF y < XY! THEN
		IF (Flag = 1 AND GrigliaNaviPC(x, y + 1) = -2) OR (Flag = 0 AND GrigliaNaviPlayer(x, y + 1) = -2) THEN vert = -1

		IF (Flag = 1 AND GrigliaNaviPC(x, y + 1) >= 1) OR (Flag = 0 AND GrigliaNaviPlayer(x, y + 1) >= 1) THEN NaveAffondata = 0: EXIT FUNCTION
	END IF

	' Se orientata orizzontalmente
	IF oriz <> 0 THEN
		i = x - 1
		DO WHILE i >= 1
			IF (Flag = 1 AND GrigliaNaviPC(i, y) = -2) OR (Flag = 0 AND GrigliaNaviPlayer(i, y) = -2) THEN
				i = i - 1
			ELSE
				IF (Flag = 1 AND GrigliaNaviPC(i, y) >= 1) OR (Flag = 0 AND GrigliaNaviPlayer(i, y) >= 1) THEN NaveAffondata = 0: EXIT FUNCTION
				EXIT DO
			END IF
		LOOP

		i = x + 1
		DO WHILE i <= XY!
			IF (Flag = 1 AND GrigliaNaviPC(i, y) = -2) OR (Flag = 0 AND GrigliaNaviPlayer(i, y) = -2) THEN
				i = i + 1
			ELSE
				IF (Flag = 1 AND GrigliaNaviPC(i, y) >= 1) OR (Flag = 0 AND GrigliaNaviPlayer(i, y) >= 1) THEN NaveAffondata = 0: EXIT FUNCTION
				EXIT DO
			END IF
		LOOP

		NaveAffondata = -1
		EXIT FUNCTION

	' Se orientata verticalmente
	ELSEIF vert <> 0 THEN
		j = y - 1
		DO WHILE j >= 1
			IF (Flag = 1 AND GrigliaNaviPC(x, j) = -2) OR (Flag = 0 AND GrigliaNaviPlayer(x, j) = -2) THEN
				j = j - 1
			ELSE
				IF (Flag = 1 AND GrigliaNaviPC(x, j) >= 1) OR (Flag = 0 AND GrigliaNaviPlayer(x, j) >= 1) THEN NaveAffondata = 0: EXIT FUNCTION
				EXIT DO
			END IF
		LOOP

		j = y + 1
		DO WHILE j <= XY!
			IF (Flag = 1 AND GrigliaNaviPC(x, j) = -2) OR (Flag = 0 AND GrigliaNaviPlayer(x, j) = -2) THEN
				j = j + 1
			ELSE
				IF (Flag = 1 AND GrigliaNaviPC(x, j) >= 1) OR (Flag = 0 AND GrigliaNaviPlayer(x, j) >= 1) THEN NaveAffondata = 0: EXIT FUNCTION
				EXIT DO
			END IF
		LOOP

		NaveAffondata = -1
		EXIT FUNCTION

	ELSE
		' Nessun vicino integro: nave affondata
		NaveAffondata = -1
	END IF

END FUNCTION

FUNCTION NaveAffondataPC (x, y)
	NaveAffondataPC = NaveAffondata(x, y, 1)
END FUNCTION

FUNCTION NaveAffondataPlayer (x, y)
	NaveAffondataPlayer = NaveAffondata(x, y, 0)
END FUNCTION

SUB PiazzaNave (Flag)
	IF Flag = 1 THEN chi$ = " PC " ELSE chi$ = " TU "
	Cornice r1naviradar + Lunghezza + 3, r1naviradar + Lunghezza + 7, c2navi + 3, c1radar - 3, 15, 0, 32, chi$
	FOR i = 1 TO Lunghezza
		FOR j = 1 TO Navi(i).Quante
			IF Flag = 0 THEN COLOR Navi(i).Lunghezza + 8, 0
			LOCATE r1naviradar + Lunghezza + 4, c2navi + 7: PRINT "Nave"
			LOCATE r1naviradar + Lunghezza + 5, c2navi + 7: PRINT "da" + STR$(Navi(i).Lunghezza)
			LOCATE r1naviradar + Lunghezza + 6, c2navi + 5: PRINT STR$(j) + " di" + STR$(Navi(i).Quante);
			IF Flag = 1 THEN
				PiazzaNavePC Navi(i).Lunghezza
			ELSE
				PiazzaNavePlayer Navi(i).Lunghezza
			END IF
		NEXT
	NEXT
	IF Flag = 0 THEN MostraGrigliaPlayer x, y, Direzione, Lunghezza
END SUB

SUB PiazzaNavePC (Lunghezza)
	DIM x, y, Direzione, Tentativi
	Tentativi = 0
	DO
		Tentativi = Tentativi + 1
		IF Tentativi > XY! ^ EXP(1) THEN
			Fallito = -1
			REDIM GrigliaNaviPC(1 TO 20, 1 TO 20)
			EXIT SUB
		END IF
		Direzione = INT(RND * 2)
		x = INT(RND * XY!) + 1
		y = INT(RND * XY!) + 1
		IF TentaPiazzaNavePC(x, y, Direzione, Lunghezza) THEN
			FOR i = 0 TO Lunghezza - 1
				IF Direzione = 0 THEN
					GrigliaNaviPC(x + i, y) = Lunghezza
				ELSE
					GrigliaNaviPC(x, y + i) = Lunghezza
				END IF
			NEXT
			EXIT SUB
		END IF
	LOOP
END SUB

SUB PiazzaNavePlayer (Lunghezza)

	DIM x, y, Direzione, tasto$, tasto
	x = CINT(XY! / 2): y = CINT(XY! / 2): Direzione = 0
	DIM xOld, yOld, DirOld
	xOld = x: yOld = y: DirOld = Direzione

	MostraGrigliaPlayer x, y, Direzione, Lunghezza

	DO
		IF xOld <> x OR yOld <> y OR DirOld <> Direzione THEN
			' Cancella nave precedente
			CALL MostraNaveTemporanea(xOld, yOld, DirOld, Lunghezza, 0)

			' Disegna nave nuova
			CALL MostraNaveTemporanea(x, y, Direzione, Lunghezza, 1)

			xOld = x: yOld = y: DirOld = Direzione
		END IF

		CLSrow 24, 3, 79, 0, 14, 1, "Usa i tasti freccia per muoverti, TAB per ruotare, Invio per piazzare"

		DO
			tasto$ = INKEY$
			IF LEN(tasto$) = 2 THEN tasto = ASC(RIGHT$(tasto$, 1))
			IF LEN(tasto$) = 1 THEN tasto = ASC(tasto$)
		LOOP WHILE tasto$ = ""

		SELECT CASE tasto
			CASE 72 ' Freccia su
				IF y > 1 THEN y = y - 1
			CASE 80 ' Freccia giu'
				IF Direzione = 1 THEN
					IF y < XY! - (Lunghezza - 1) THEN y = y + 1
				ELSE
					IF y < XY! THEN y = y + 1
				END IF
			CASE 75 ' Freccia sinistra
				IF x > 1 THEN x = x - 1
			CASE 77 ' Freccia destra
				IF Direzione = 0 THEN
					IF x < XY! - (Lunghezza - 1) THEN x = x + 1
				ELSE
					IF x < XY! THEN x = x + 1
				END IF
			CASE 8, 9 ' Back e/o TAB
				' Ruota: ma ricentra se la nuova direzione farebbe uscire la nave
				Direzione = 1 - Direzione
				IF Direzione = 0 AND x > XY! - (Lunghezza - 1) THEN
					x = XY! - (Lunghezza - 1)
				ELSEIF Direzione = 1 AND y > XY! - (Lunghezza - 1) THEN
					y = XY! - (Lunghezza - 1)
				END IF
			CASE 13, 32 ' Invio e/o spazio
				IF TentaPiazzaNavePlayer(x, y, Direzione, Lunghezza) THEN
					FOR i = 0 TO Lunghezza - 1
						IF Direzione = 0 THEN
							GrigliaNaviPlayer(x + i, y) = Lunghezza
						ELSE
							GrigliaNaviPlayer(x, y + i) = Lunghezza
						END IF
					NEXT
					PLAY playOk$
					EXIT DO
				ELSE
					CLSrow 24, 3, 79, 0, 14, 1, "Posizione non valida!" + Pausa$
					PLAY playErrato$
					k$ = INPUT$(1)
				END IF
			CASE 27: Fine 1
		END SELECT
	LOOP
END SUB

SUB ProvaColpo (nx, ny, trovato)
	' Il PC spara
	' trovato: 0 = nulla, -1 = ha sparato (mancato/colpito), 2 = appena affondato
   
	trovato = 0
   
	IF nx < 1 OR nx > XY! OR ny < 1 OR ny > XY! THEN EXIT SUB
   
	LOCATE r1naviradar + ny, c1navi - 1 + 2 * nx
   
	IF GrigliaNaviPlayer(nx, ny) = 0 THEN
		GrigliaNaviPlayer(nx, ny) = -1
		COLOR 17, 7: PRINT "()";
		CLSrow 24, 3, 79, 0, 14, 1, "Il PC ha mancato in" + STR$(nx) + STR$(ny) + Pausa$
		PLAY playAcqua$
		trovato = -1
		EXIT SUB
	END IF

	IF GrigliaNaviPlayer(nx, ny) >= 1 THEN
		' Colpito
		LunghezzaNaveInseguita = GrigliaNaviPlayer(nx, ny)
		GrigliaNaviPlayer(nx, ny) = -2
		COLOR 28, 0: PRINT "<>";
		CLSrow 24, 3, 79, 0, 14, 1, "Il PC ha colpito in" + STR$(nx) + STR$(ny) + Pausa$
		PLAY playColpito$

		' Registra il colpo nella lista di inseguimento
		IF NumColpiInseguiti = 0 THEN
			NumColpiInseguiti = 1
			ColpiInseguiti(1) = nx
			ColpiInseguiti(2) = ny
		ELSE
			NumColpiInseguiti = NumColpiInseguiti + 1
			ColpiInseguiti(NumColpiInseguiti * 2 - 1) = nx
			ColpiInseguiti(NumColpiInseguiti * 2) = ny
		END IF

		trovato = -1

		' Controllo immediato affondamento
		IF NumColpiInseguiti >= LunghezzaNaveInseguita THEN
			IF NaveAffondataPlayer(ColpiInseguiti(1), ColpiInseguiti(2)) THEN
				MarcaContornoNavePlayer ColpiInseguiti(1), ColpiInseguiti(2)
				NumColpiInseguiti = 0
				CLSrow 24, 3, 79, 0, 14, 1, "Il PC ha affondato una tua nave!" + Pausa$
				trovato = 2 ' segnale speciale: affondata adesso
				PLAY playAffondato$
			END IF
		END IF
	END IF

END SUB

FUNCTION TentaPiazzaNave (x, y, Direzione, Lunghezza, Flag)
	IF Direzione = 0 AND x + Lunghezza - 1 > XY! THEN TentaPiazzaNave = 0: EXIT FUNCTION
	IF Direzione = 1 AND y + Lunghezza - 1 > XY! THEN TentaPiazzaNave = 0: EXIT FUNCTION
	FOR i = 0 TO Lunghezza - 1
		FOR dx = -1 TO 1
			FOR dy = -1 TO 1
				IF Direzione = 0 THEN
					nx = x + i + dx: ny = y + dy
				ELSE
					nx = x + dx: ny = y + i + dy
				END IF
				IF nx >= 1 AND nx <= XY! AND ny >= 1 AND ny <= XY! THEN
					IF Flag THEN
						IF GrigliaNaviPC(nx, ny) <> 0 THEN TentaPiazzaNave = 0: EXIT FUNCTION
					ELSE
						IF GrigliaNaviPlayer(nx, ny) <> 0 THEN TentaPiazzaNave = 0: EXIT FUNCTION
					END IF
				END IF
			NEXT dy
		NEXT dx
	NEXT i
	TentaPiazzaNave = -1
END FUNCTION

FUNCTION TentaPiazzaNavePC (x, y, Direzione, Lunghezza)
	TentaPiazzaNavePC = TentaPiazzaNave(x, y, Direzione, Lunghezza, 1)
END FUNCTION

FUNCTION TentaPiazzaNavePlayer (x, y, Direzione, Lunghezza)
	TentaPiazzaNavePlayer = TentaPiazzaNave(x, y, Direzione, Lunghezza, 0)
END FUNCTION

SUB TestPC
   
	DEF SEG = &H40
	IF PEEK(&H49) = &H7 THEN
		PRINT "Scheda video monochrome."
		PRINT "Battaglia navale richiede CGA o superiore."
		END
	END IF

END SUB

SUB Z.spiaGrigliaPC
	' Spia griglia PC per collaudo
	COLOR 8, 7
	FOR j = 1 TO XY!
		LOCATE j + r1naviradar, c1radar + 1, 0
		FOR i = 1 TO XY!
			IF GrigliaNaviPC(i, j) > 0 THEN PRINT CHR$(219);  ELSE PRINT CHR$(254);
		NEXT i
	NEXT j
	COLOR 7, 1
END SUB

