get_ship_fleet(10, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10],
    X_Coords = [X1, X2, X3, X4, X5, X6, X7, X8, X9, X10],
    Y_Coords = [Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8, Y9, Y10],

    % assign shapes of each ship
    domain([S1, S2, S3, S4], 1, 1),
    domain([S5, S6, S7], 2, 3),
    domain([S8, S9], 4, 5),
    domain([S10], 6, 7),

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4],
        [5,6,7],
        [8,9]
    ].