' =========================
' PIAZZAMENTO COMPATTO NAVI
' =========================

' Calcolo approssimativo per fare il confronto con BN2TEST2

DECLARE FUNCTION SpazioLibero! (r!, c!, lun!, orient!)
DECLARE SUB Piazza (r!, c!, lun!, orient!, simbolo$)

CONST MAXN = 20

TYPE TipoNave
    Lunghezza AS INTEGER
    quante    AS INTEGER
END TYPE

DIM SHARED Navi(5) AS TipoNave

DIM SHARED G$(1 TO MAXN, 1 TO MAXN)
DIM SHARED XY

OPEN "BN2TEST4.DAT" FOR OUTPUT AS #1

FOR XY = 8 TO 20

    ' --- Reset griglia ---
    FOR r = 1 TO XY
        FOR c = 1 TO XY
            G$(r, c) = "."
        NEXT
    NEXT

    ' --- Calcolo dinamico delle navi ---
    IF XY > 10 THEN Lunghezza = 5 ELSE Lunghezza = 4

    PRINT "Griglia da:"; XY; "- Navi:";
    PRINT #1, "Griglia da:"; XY; "Navi:";
    FOR i = 1 TO Lunghezza
        Navi(i).Lunghezza = 1 + Lunghezza - i
        Navi(i).quante = CINT(i * XY / 10 - 1 / XY)
        PRINT Navi(i).quante; " da "; Navi(i).Lunghezza;
        PRINT #1, Navi(i).quante; " da "; Navi(i).Lunghezza;
    NEXT
    PRINT
    PRINT #1, ""

    ' --- Piazzamento compatto delle navi ---
    FOR i = 1 TO Lunghezza
        FOR q = 1 TO Navi(i).quante
            nave = Navi(i).Lunghezza
            ok = 0
            FOR r = 1 TO XY: IF ok THEN EXIT FOR
                FOR c = 1 TO XY: IF ok THEN EXIT FOR
                    FOR orient = 0 TO 1
                        ok = SpazioLibero(r, c, nave, orient)
                        IF ok THEN
                            CALL Piazza(r, c, nave, orient, LTRIM$(STR$(nave)))
                            EXIT FOR
                        END IF
                    NEXT
                NEXT
            NEXT
            IF NOT ok THEN PRINT " Non riesco a piazzare nave da "; nave
        NEXT
    NEXT

    ' --- Stampa griglia ---
    FOR r = 1 TO XY
        riga$ = ""
        FOR c = 1 TO XY
            riga$ = riga$ + G$(r, c)
        NEXT
        PRINT riga$
        PRINT #1, riga$
    NEXT

    ' --- Conta celle occupate ---
    occupate = 0
    FOR r = 1 TO XY
        FOR c = 1 TO XY
            IF G$(r, c) <> "." THEN occupate = occupate + 1
        NEXT
    NEXT

    PRINT "Celle occupate (navi + contorno) = "; occupate; " su "; XY * XY; " ("; INT(occupate * 100 / (XY * XY)); "%)"
    PRINT
    PRINT #1, "Celle occupate (navi + contorno) = "; occupate; " su "; XY * XY; " ("; INT(occupate * 100 / (XY * XY)); "%)"
    PRINT #1, ""

NEXT

END

' ---------------------------------------
' Procedura: piazza nave e marca contorno
' ---------------------------------------
SUB Piazza (r, c, lun, orient, simbolo$)
    FOR k = 1 TO lun
        IF orient = 0 THEN
            rr = r
            cc = c + k - 1
        ELSE
            rr = r + k - 1
            cc = c
        END IF
        G$(rr, cc) = simbolo$
        ' contorno
        FOR dr = -1 TO 1
            FOR dc = -1 TO 1
                r2 = rr + dr: c2 = cc + dc
                IF r2 >= 1 AND r2 <= XY AND c2 >= 1 AND c2 <= XY THEN
                    IF G$(r2, c2) = "." THEN G$(r2, c2) = ":"
                END IF
            NEXT
        NEXT
    NEXT
END SUB

' -------------------------------------
' Funzione: controlla se una nave entra
' -------------------------------------
FUNCTION SpazioLibero (r, c, lun, orient)
    SpazioLibero = -1
    FOR k = 1 TO lun
        IF orient = 0 THEN
            rr = r: cc = c + k - 1
        ELSE
            rr = r + k - 1: cc = c
        END IF
        IF rr < 1 OR rr > XY OR cc < 1 OR cc > XY THEN
            SpazioLibero = 0: EXIT FUNCTION
        END IF
        IF G$(rr, cc) <> "." THEN
            SpazioLibero = 0: EXIT FUNCTION
        END IF
    NEXT
END FUNCTION

