' BN2TEST1.BAS
' Test crono piazzamento navi in Battaglia navale 2.0
' Griglie da 8x8 a 20x20 (debug se num. di simulazioni = 1)
' By Marco da Venezia, 1987

DEFINT A-Z

DECLARE FUNCTION TentaPiazzaNave (x, y, Direzione, Lunghezza)
DECLARE SUB PiazzaNave (Lunghezza)
DECLARE SUB MostraGriglia ()
DECLARE SUB DebugLog (Lunghezza, x, y, Direzione, Tentativi)
DECLARE SUB Concludi ()

CLS

' Input dimensione griglia e numero di partite
DIM SHARED XY!, Partite
INPUT "Griglia (8-20), Partite"; XY!, Partite
IF XY! < 8 OR XY! > 20 THEN XY! = 10

REDIM SHARED GrigliaNavi(1 TO 20, 1 TO 20)

TYPE TipoNave
    Lunghezza AS INTEGER
    quante   AS INTEGER
END TYPE

DIM SHARED Navi(5) AS TipoNave

' Calcolo dinamico delle navi
IF XY! > 10 THEN Lunghezza = 5 ELSE Lunghezza = 4
PRINT "Navi:";
FOR i = 1 TO Lunghezza
    Navi(i).Lunghezza = 1 + Lunghezza - i
    Navi(i).quante = CINT(i * XY! / 10 - 1 / XY!)
    PRINT Navi(i).quante; "da"; Navi(i).Lunghezza;
NEXT
PRINT

DIM SHARED rigaLog, colDebug
rigaLog = 3: colDebug = XY! + 5

RANDOMIZE TIMER

DIM SHARED TentTot!, TotTentTot!, Falliti

FOR p = 1 TO Partite

    TentTot! = 0

    ' Reset griglia navi
    REDIM GrigliaNavi(1 TO 20, 1 TO 20) ' piu' veloce di reset for-next
   
    'FOR y = 1 TO XY!
    '    FOR x = 1 TO XY!
    '        GrigliaNavi(x, y) = 0
    '    NEXT
    'NEXT

    StartTime! = TIMER

    ' Posizionamento navi
    FOR i = 1 TO Lunghezza
        FOR j = 1 TO Navi(i).quante
            PiazzaNave Navi(i).Lunghezza
            IF Falliti THEN
                MostraGriglia
                Concludi
                PRINT "nave da"; Navi(i).Lunghezza; j; "di"; Navi(i).quante
                PRINT #1, " nave da"; Navi(i).Lunghezza; j; "di"; Navi(i).quante;
                END
            END IF
        NEXT j
    NEXT i

    EndTime! = TIMER
   
    TotTentTot! = TotTentTot! + TentTot!

    ' Visualizza num. tentativi totali di piazzamento durante le partite 2-100
    IF Partite > 1 AND Partite < 101 THEN PRINT TentTot!;

NEXT p

' Output grafico della griglia se partite = 1
IF Partite = 1 THEN
    MostraGriglia ' Remarkare su XT per precisione crono
    PRINT USING "Tempo flotta: ###.##"; EndTime! - StartTime!
    PRINT "Tentativi totali:"; TentTot!;
END IF

Concludi

END

SUB Concludi
    Media = TotTentTot! \ Partite
    PRINT "- Media:"; Media; "- Falliti:"; Falliti;
    OPEN "BN2TEST1.DAT" FOR APPEND AS #1
    IF LOF(1) = 0 THEN
        PRINT #1, "  Dim. "; TAB(12); "Num. di"; TAB(24); "  Media  "; TAB(36); "Piazzamenti"
        PRINT #1, "griglia"; TAB(12); "partite"; TAB(24); "tentativi"; TAB(36); "  falliti  "
        PRINT #1, STRING$(47, "-")
    END IF
    PRINT #1, CHR$(13)
    PRINT #1, USING "  ##        ####          ###         ###"; XY!; Partite; Media; Falliti;
END SUB

SUB DebugLog (Lunghezza, x, y, Direzione, Tentativi)
    ' Stampa coordinate e info nave
    LOCATE rigaLog, colDebug
    PRINT USING "L. #  ## ## ### "; Lunghezza; x; y; Tentativi;
    IF Direzione = 0 THEN PRINT "oriz." ELSE PRINT "vert."
    rigaLog = rigaLog + 1
    IF rigaLog > XY! + 2 THEN
        rigaLog = 3
        colDebug = colDebug + 24
    END IF
END SUB

SUB MostraGriglia
    LOCATE 3, 1
    FOR y = 1 TO XY!
        FOR x = 1 TO XY!
            IF GrigliaNavi(x, y) = 0 THEN
                COLOR 7, 1: PRINT ".";
            ELSE
                COLOR GrigliaNavi(x, y), 7: PRINT CHR$(48 + GrigliaNavi(x, y));
            END IF
        NEXT x
        COLOR 7, 0
        PRINT
    NEXT y
END SUB

SUB PiazzaNave (Lunghezza)
    Tentativi = 0
    DO
        Tentativi = Tentativi + 1
        TentTot! = TentTot! + 1
        ' Limite adattivo: dipende dall'area della griglia
        IF Tentativi > XY! ^ EXP(1) THEN
            Falliti = Falliti + 1
            EXIT SUB
        END IF
        ' Direzione randomizzata
        Direzione = INT(RND * 2) ' 0 = orizzontale, 1 = verticale
        x = INT(RND * XY!) + 1
        y = INT(RND * XY!) + 1
        IF TentaPiazzaNave(x, y, Direzione, Lunghezza) THEN
            FOR i = 0 TO Lunghezza - 1
                IF Direzione = 0 THEN
                    GrigliaNavi(x + i, y) = Lunghezza
                ELSE
                    GrigliaNavi(x, y + i) = Lunghezza
                END IF
            NEXT i
            IF Partite = 1 THEN CALL DebugLog(Lunghezza, x, y, Direzione, Tentativi)
            EXIT SUB
        END IF
    LOOP
END SUB

FUNCTION TentaPiazzaNave (x, y, Direzione, Lunghezza)
   
    ' Controllo dei bordi
    IF Direzione = 0 THEN
        IF x + Lunghezza - 1 > XY! THEN TentaPiazzaNave = 0: EXIT FUNCTION
    ELSE
        IF y + Lunghezza - 1 > XY! THEN TentaPiazzaNave = 0: EXIT FUNCTION
    END IF

    ' Controllo collisioni con early exit
    FOR i = 0 TO Lunghezza - 1
        FOR dx = -1 TO 1
            FOR dy = -1 TO 1
                IF Direzione = 0 THEN
                    nx = x + i + dx: ny = y + dy
                ELSE
                    nx = x + dx: ny = y + i + dy
                END IF
                IF nx >= 1 AND nx <= XY! AND ny >= 1 AND ny <= XY! THEN
                    IF GrigliaNavi(nx, ny) <> 0 THEN
                        TentaPiazzaNave = 0
                        EXIT FUNCTION
                    END IF
                END IF
            NEXT dy
        NEXT dx
    NEXT i

    TentaPiazzaNave = -1

END FUNCTION

