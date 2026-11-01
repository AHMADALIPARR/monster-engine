* Verification-workload allocation model (MPS format)
* Tasks: T1 cost 3 coverage 10; T2 cost 2 coverage 9; T3 cost 4 coverage 13; T4 cost 3 coverage 8
* Budget B = 8 hours. Linking constraint: T2 requires T1 (T2 - T1 <= 0).
* Hand-computed optimum: T1 + T2 + T4, cost 3 + 2 + 3 = 8, coverage 10 + 9 + 8 = 27.
NAME          WORKLOAD
OBJSENSE
 MAX
ROWS
 N  OBJ
 L  BUDGET
 L  LINK
COLUMNS
    MARKER                 'MARKER'                 'INTORG'
    T1        OBJ              10
    T1        BUDGET            3
    T1        LINK             -1
    T2        OBJ               9
    T2        BUDGET            2
    T2        LINK              1
    T3        OBJ              13
    T3        BUDGET            4
    T4        OBJ               8
    T4        BUDGET            3
    MARKER                 'MARKER'                 'INTEND'
RHS
    RHS       BUDGET            8
    RHS       LINK              0
BOUNDS
 BV BND       T1
 BV BND       T2
 BV BND       T3
 BV BND       T4
ENDATA
