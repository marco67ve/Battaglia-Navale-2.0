' ==============================================
'  TEST 5 - Istogramma flotte compatte vs random
' ==============================================

DECLARE SUB StampaBarra (valore%, car%)

DEFINT A-Z

CONST MAX = 13
DIM Compatto(MAX), Randomizzato(MAX)

WIDTH 80, 50
PRINT "ISTOGRAMMA FLOTTE (compatto vs Randomizzato)"
PRINT

' ------------------------------
' Leggi dati da DATA (colonna P+C st. di BN2TEST2.DAT
' ------------------------------
FOR i = 1 TO MAX: READ Compatto(i): NEXT
FOR i = 1 TO MAX: READ Randomizzato(i): NEXT

' ------------------------------
' Stampa istogrammi
' ------------------------------
OPEN "BN2TEST5.DAT" FOR OUTPUT AS #1
FOR i = 1 TO MAX
    COLOR 7, 0
    PRINT USING "Griglia ##: "; i + 7
    PRINT #1, USING "Griglia ##: "; i + 7

    ' Compatto in verde
    COLOR 2, 0
    CALL StampaBarra(Compatto(i), 176)

    ' Randomizzato in ciano
    COLOR 3, 0
    CALL StampaBarra(Randomizzato(i), 177)
NEXT

COLOR 7, 0

' Questo e' per verificare C/R che dovrebbe corrispondere
' al coefficiente 2*Lunghezza+4.21 (circa 0.711) del test n.2

DIM SHARED SommaC, SommaR
SommaC = 0
SommaR = 0

FOR i = 1 TO 13
    SommaC = SommaC + Compatto(i)
    SommaR = SommaR + Randomizzato(i)
NEXT

PRINT
PRINT "--------------------------------------"
PRINT "Totale percentuali flotte compatte ="; SommaC
PRINT "Totale percentuali flotte Randomizzato   ="; SommaR
PRINT "Rapporto C/R ="; USING "##.###"; SommaC / SommaR
PRINT "--------------------------------------"

PRINT #1,
PRINT #1, "--------------------------------------"
PRINT #1, "Totale percentuali flotte compatte ="; SommaC
PRINT #1, "Totale percentuali flotte Randomizzato   ="; SommaR
PRINT #1, "Rapporto C/R ="; USING "##.###"; SommaC / SommaR
PRINT #1, "--------------------------------------"

' ------------------------------
' Dati: percentuali (13 valori)
' ------------------------------
DATA 62,66,56,84,80,76,69,60,62,56,55,55,48
DATA 94,98,85,115,115,105,98,85,88,81,78,75,69

END

' ------------------------------
' Sub: stampa barra con 219/221 (176/177 su file)
' ------------------------------
SUB StampaBarra (valore, car)
    DIM blocchi, resto

    blocchi = valore \ 2
    resto = valore MOD 2

    FOR k = 1 TO blocchi
        PRINT CHR$(219);
        PRINT #1, CHR$(car);
    NEXT

    IF resto THEN
        PRINT CHR$(221);
        PRINT #1, CHR$(221);
    END IF

    PRINT " "; valore; "%"
    PRINT #1, " "; valore; "%"
END SUB

