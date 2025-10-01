' BN2TEST2.BAS
' Stampa elenco numero navi e celle di Battaglia navale 2.0
' con colonna contorno stimato
' By Marco da Venezia, 1987

' Calcolo ingombro stimato per ogni nave: 2.21 * Lunghezza + 4.1
' Coefficiente derivato da test empirici su griglie da 8x8 a 20x20
' Tiene conto del contorno condiviso e della frammentazione spaziale
' Superare il 100% di ingombro stimato puo' causare fallimenti di piazzamento
' relativi all'ultima nave da una cella nelle griglie da 11x11 a 13x13
' (BN2 fixa automaticamente ricostruendo ex novo il piazzamento)

DEFINT A-Z

CLS

REDIM SHARED GrigliaNavi(1 TO 20, 1 TO 20)

TYPE TipoNave
    Lunghezza AS INTEGER
    Quante AS INTEGER
END TYPE

DIM SHARED navi(5) AS TipoNave

OPEN "BN2TEST2.DAT" FOR OUTPUT AS #1

PRINT "Griglia"; TAB(9); "Navi"; TAB(15); "Celle"; TAB(22); "G^2"; TAB(28); "Perc."; TAB(35); "C+C"; TAB(40); "P+C"; TAB(47); "P+C st."; TAB(56); "Navi"
PRINT STRING$(79, "-")
PRINT #1, "Griglia"; TAB(9); "Navi"; TAB(15); "Celle"; TAB(22); "G^2"; TAB(28); "Perc."; TAB(35); "C+C"; TAB(40); "P+C"; TAB(47); "P+C st."; TAB(56); "Navi"
PRINT #1, STRING$(79, "-")

FOR XY = 8 TO 20

    REDIM SHARED GrigliaNavi(1 TO 20, 1 TO 20)
    IF XY > 10 THEN Lunghezza = 5 ELSE Lunghezza = 4
    TotNavi = 0: celle = 0: CelleConContorno! = 0: CelleConContornoStimato = 0

    RigaNavi$ = ""

    FOR i = 1 TO Lunghezza
        navi(i).Lunghezza = 1 + Lunghezza - i
        navi(i).Quante = CINT(i * XY / 10 - 1 / XY)
        RigaNavi$ = RigaNavi$ + STR$(navi(i).Quante) + "x" + LTRIM$(STR$(navi(i).Lunghezza)) + " "
        TotNavi = TotNavi + navi(i).Quante
        celle = celle + navi(i).Lunghezza * navi(i).Quante
        CelleConContorno! = CelleConContorno! + navi(i).Quante * (3 * navi(i).Lunghezza + 6)
        CelleConContornoStimato = CelleConContornoStimato + navi(i).Quante * (2.21 * navi(i).Lunghezza + 4.1)
    NEXT

    PercNormale = 100 * celle / (XY * XY)
    PercContorno! = 100 * CelleConContorno! / (XY * XY)
    PercContornoStimato = 100 * CelleConContornoStimato / (XY * XY)

    PRINT USING "##"; XY;
    PRINT USING "##"; TAB(9); TotNavi;
    PRINT USING "##"; TAB(15); celle;
    PRINT USING "###"; TAB(22); XY ^ 2;
    PRINT USING "##.#"; TAB(28); PercNormale;
    PRINT USING "###"; TAB(35); CelleConContorno!;
    PRINT USING "###.#"; TAB(40); PercContorno!;
    PRINT USING "###.#"; TAB(47); PercContornoStimato;
    PRINT TAB(55); RigaNavi$

    PRINT #1, USING "##"; XY;
    PRINT #1, USING "##"; TAB(9); TotNavi;
    PRINT #1, USING "##"; TAB(15); celle;
    PRINT #1, USING "###"; TAB(22); XY ^ 2;
    PRINT #1, USING "##.#"; TAB(28); PercNormale;
    PRINT #1, USING "###"; TAB(35); CelleConContorno!;
    PRINT #1, USING "###.#"; TAB(40); PercContorno!;
    PRINT #1, USING "###.#"; TAB(47); PercContornoStimato;
    PRINT #1, TAB(55); RigaNavi$

NEXT
END

