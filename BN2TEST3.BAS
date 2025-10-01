' BN2TEST3.BAS
' Collaudo punteggi Battaglia navale 2.0
' By Marco da Venezia, 1987

' Navi non colpite = celle di valore Lunghezza nave
' Navi colpite = celle di valore -2
' Colpi in acqua = celle di valore -1
' Colpi non sparati = celle di valore 0
' Punti = somma valori celle

DEFINT A-Z

WIDTH 80, 50

REDIM GrigliaNavi(1 TO 20, 1 TO 20) ' Inizializza griglia ridimensionabile

' Definizione delle navi
TYPE TipoNave
    Lunghezza AS INTEGER
    Quante AS INTEGER
END TYPE

DIM navi(5) AS TipoNave ' Dimensione massima delle navi=5

' Array unico per il caso normale: (XY,1)=Punteggio ; (XY,2)=Secondi
DIM CasoNormale(8 TO 20, 1 TO 2)

OPEN "BN2TEST3.DAT" FOR OUTPUT AS #1

PRINT "Griglia"; TAB(9); "Navi"; TAB(15); "Celle"; TAB(22); "G^2"; TAB(28); "Pt.G"; TAB(35); "Pt.PC"; TAB(42); "Punt.sec."; TAB(53); "Navi"
PRINT STRING$(79, "-")
PRINT #1, "Griglia"; TAB(9); "Navi"; TAB(15); "Celle"; TAB(22); "G^2"; TAB(28); "Pt.G"; TAB(35); "Pt.PC"; TAB(42); "Punt.sec."; TAB(53); "Navi"
PRINT #1, STRING$(79, "-")

FOR XY = 8 TO 20

    REDIM GrigliaNavi(1 TO 20, 1 TO 20) ' Resetta la griglia
    IF XY > 10 THEN Lunghezza = 5 ELSE Lunghezza = 4 ' Navi fino 5 celle per griglie>10x10
    TotNavi = 0: CelleNavi = 0: CelleAcqua = 0
    ColpiSprecati = 0: Secondi = 0
    PuntG = 0: PuntPC = 0
    RigaNavi$ = ""

    ' Numero e dimensionamento dinamico delle navi
    FOR i = 1 TO Lunghezza
        navi(i).Lunghezza = 1 + Lunghezza - i
        navi(i).Quante = CINT(i * XY / 10 - 1 / XY)
        RigaNavi$ = RigaNavi$ + STR$(navi(i).Quante) + "x" + LTRIM$(STR$(navi(i).Lunghezza)) + " "
        TotNavi = TotNavi + navi(i).Quante
        CelleNavi = CelleNavi + navi(i).Lunghezza * navi(i).Quante
        CelleAcqua = XY ^ 2 - CelleNavi
    NEXT

    PRINT USING "##"; XY;
    PRINT USING "##"; TAB(9); TotNavi;
    PRINT USING "##"; TAB(15); CelleNavi;
    PRINT USING "###"; TAB(22); XY ^ 2;

    PRINT #1, USING "##"; XY;
    PRINT #1, USING "##"; TAB(9); TotNavi;
    PRINT #1, USING "##"; TAB(15); CelleNavi;
    PRINT #1, USING "###"; TAB(22); XY ^ 2;

    ' Caso limite A) fortuna sfacciata
    ' Player ha colpito subito tutte le navi
    ' PC ha sparato sempre in acqua
   
    Secondi = 5 * CelleNavi
   
    PuntiG = CelleNavi * -2
    PuntiPC = CelleNavi
    Punteggio = -PuntiG + PuntiPC + XY ^ 2
    Punteggio = 10 * (Punteggio - ColpiSprecati) - Secondi
   
    PRINT USING "####"; TAB(28); PuntiG;
    PRINT USING "####"; TAB(35); PuntiPC;
    PRINT USING "#####"; TAB(42); Punteggio; Secondi;
   
    PRINT #1, USING "####"; TAB(28); PuntiG;
    PRINT #1, USING "####"; TAB(35); PuntiPC;
    PRINT #1, USING "#####"; TAB(42); Punteggio; Secondi;

    PRINT TAB(52); RigaNavi$
    PRINT #1, TAB(52); RigaNavi$
   
    ' Caso limite B) battaglia fortunata ma lunga
    ' Player ha colpito tutte le navi e acqua-2*navi
    ' PC ha sparato sempre in acqua

    Secondi = 5 * XY ^ 2 - 2 * CelleNavi
   
    PuntiG = CelleNavi * -2 + (XY ^ 2 - 2 * CelleNavi) * -1
    PuntiPC = (XY ^ 2 - CelleNavi) * -1
    Punteggio = -PuntiG + PuntiPC + XY ^ 2
    Punteggio = 10 * (Punteggio - ColpiSprecati) - Secondi

    PRINT USING "####"; TAB(28); PuntiG;
    PRINT USING "####"; TAB(35); PuntiPC;
    PRINT USING "#####"; TAB(42); Punteggio; Secondi;

    PRINT #1, USING "####"; TAB(28); PuntiG;
    PRINT #1, USING "####"; TAB(35); PuntiPC;
    PRINT #1, USING "#####"; TAB(42); Punteggio; Secondi;

    ' Caso normale
    ' Player ha colpito tutte le navi e ha sparato in acqua per il 50% delle celle rimanenti
    ' PC ha colpito meta' delle navi e ha sparato in acqua per il resto

    Secondi = 5 * XY ^ 2 / 2

    ColpiG = CelleNavi + INT((XY ^ 2 - CelleNavi) / 2)
    ColpiPC = INT(CelleNavi / 2) + (XY ^ 2 - CelleNavi)
   
    PuntiG = CelleNavi * -2 + (ColpiG - CelleNavi) * -1
    PuntiPC = INT(CelleNavi / 2) + (XY ^ 2 - CelleNavi) * -1
    Punteggio = -PuntiG + PuntiPC + XY ^ 2
    Punteggio = 10 * (Punteggio - ColpiSprecati) - Secondi

    PRINT USING "####"; TAB(28); PuntiG;
    PRINT USING "####"; TAB(35); PuntiPC;
    PRINT USING "#####"; TAB(42); Punteggio; Secondi

    PRINT #1, USING "####"; TAB(28); PuntiG;
    PRINT #1, USING "####"; TAB(35); PuntiPC;
    PRINT #1, USING "#####"; TAB(42); Punteggio; Secondi

    ' Salva valori del caso normale
    CasoNormale(XY, 1) = Punteggio
    CasoNormale(XY, 2) = Secondi

NEXT

' PRINT CSRLIN ' Qui siamo alla riga 42 di 50
               ' istogramma orizzontale con chr$ di 219 e di 221 in nuova pagina

PRINT : PRINT "Premi un tasto per visualizzare il grafico...";
SLEEP
WIDTH 80, 25
PRINT "ISTOGRAMMA PUNTEGGI PER GRIGLIA (Scala: 1 char = 100 punti)"
PRINT STRING$(80, "-")

FOR XY = 8 TO 20

    ' Lettura valori dal CasoNormale
    Punteggio = CasoNormale(XY, 1)
    Secondi = CasoNormale(XY, 2)

    ' Istogramma
    IF XY MOD 2 = 0 THEN
        colore = 2
        simbolo = 176
    ELSE
        colore = 3
        simbolo = 177
    END IF

    LOCATE XY - 5: COLOR colore, 0: PRINT USING "Griglia ## "; XY;
    barra$ = STRING$(Punteggio \ 100, CHR$(219))
    PRINT barra$;
    IF Punteggio MOD 100 > 50 THEN PRINT CHR$(221);
    PRINT Secondi; "s.";
    LOCATE , 10 + LEN(barra$) \ 2: COLOR 0, colore: PRINT Punteggio

    PRINT #1, USING "Griglia ## "; XY;
    barra$ = STRING$(Punteggio \ 100, CHR$(simbolo))
    PRINT #1, barra$; Punteggio; "p."; Secondi; "s."

NEXT

COLOR 7, 0

END

