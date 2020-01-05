/**
 * Get ship fleet
 * get_ship_fleet(+NShips, +ShipsShapes, +X_Coords, +Y_Coords, +LexGroups)
 * Solves a battleships problem, given the provided input values.
 * Finds the position of all the ships in the board.
 *
 * NShips -> Number of ships in the fleet.
 * ShipsShapes -> Variables that represent the ships shapes.
 * X_Coords -> Variables that represent the ships' x coordinates.
 * Y_Coords -> Variables that represent the ships' y coordinates.
 * LexGroups -> List of lexical groups to be used in geost.
 */
 get_ship_fleet(6, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6],
    create_n_vars(6, X_Coords),
    create_n_vars(6, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3], 1, 1), % 3 of size 1
    domain([S4, S5], 2, 3), % 2 of size 2
    domain([S6], 4, 5), % 1 of size 3

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3],
        [4,5]
    ].

get_ship_fleet(7, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7],
    create_n_vars(7, X_Coords),
    create_n_vars(7, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3, S4], 1, 1), % 4 of size 1
    domain([S5, S6], 2, 3), % 2 of size 2
    domain([S7], 4, 5), % 1 of size 3

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4],
        [5,6]
    ].

get_ship_fleet(8, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8],
    create_n_vars(8, X_Coords),
    create_n_vars(8, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3, S4], 1, 1), % 4 of size 1
    domain([S5, S6, S7], 2, 3), % 3 of size 2
    domain([S8], 4, 5), % 1 of size 3

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4],
        [5,6,7]
    ].

get_ship_fleet(9, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9],
    create_n_vars(9, X_Coords),
    create_n_vars(9, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3, S4], 1, 1), % 4 of size 1
    domain([S5, S6, S7], 2, 3), % 3 of size 2
    domain([S8, S9], 4, 5), % 2 of size 3

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4],
        [5,6,7],
        [8,9]
    ].

get_ship_fleet(10, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10],
    create_n_vars(10, X_Coords),
    create_n_vars(10, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3, S4], 1, 1), % 4 of size 1
    domain([S5, S6, S7], 2, 3), % 3 of size 2
    domain([S8, S9], 4, 5), % 2 of size 3
    domain([S10], 6, 7), % 1 of size 4

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4],
        [5,6,7],
        [8,9]
    ].

get_ship_fleet(11, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11],
    create_n_vars(11, X_Coords),
    create_n_vars(11, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3, S4, S5], 1, 1), % 5 of size 1
    domain([S6, S7, S8], 2, 3), % 3 of size 2
    domain([S9, S10], 4, 5), % 2 of size 3
    domain([S11], 6, 7), % 1 of size 4

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4,5],
        [6,7,8],
        [9,10]
    ].

get_ship_fleet(12, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12],
    create_n_vars(12, X_Coords),
    create_n_vars(12, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3, S4, S5], 1, 1), % 5 of size 1
    domain([S6, S7, S8, S9], 2, 3), % 4 of size 2
    domain([S10, S11], 4, 5), % 2 of size 3
    domain([S12], 6, 7), % 1 of size 4

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4,5],
        [6,7,8,9],
        [10,11]
    ].

get_ship_fleet(13, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13],
    create_n_vars(13, X_Coords),
    create_n_vars(13, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3, S4, S5], 1, 1), % 5 of size 1
    domain([S6, S7, S8, S9], 2, 3), % 4 of size 2
    domain([S10, S11, S12], 4, 5), % 3 of size 3
    domain([S13], 6, 7), % 1 of size 4

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4,5],
        [6,7,8,9],
        [10,11,12]
    ].

get_ship_fleet(14, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14],
    create_n_vars(14, X_Coords),
    create_n_vars(14, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3, S4, S5], 1, 1), % 5 of size 1
    domain([S6, S7, S8, S9], 2, 3), % 4 of size 2
    domain([S10, S11, S12], 4, 5), % 3 of size 3
    domain([S13, S14], 6, 7), % 2 of size 4

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4,5],
        [6,7,8,9],
        [10,11,12],
        [13,14]
    ].

get_ship_fleet(15, ShipsShapes, X_Coords, Y_Coords, LexGroups) :-
    % domain variables
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15],
    create_n_vars(15, X_Coords),
    create_n_vars(15, Y_Coords),

    % assign shapes of each ship
    domain([S1, S2, S3, S4, S5], 1, 1), % 5 of size 1
    domain([S6, S7, S8, S9], 2, 3), % 4 of size 2
    domain([S10, S11, S12], 4, 5), % 3 of size 3
    domain([S13, S14], 6, 7), % 2 of size 4
    domain([S15], 8, 9), % 1 of size 5

    % IDs separated by ship length, to be used in geost Options
    LexGroups = [
        [1,2,3,4,5],
        [6,7,8,9],
        [10,11,12],
        [13,14]
    ].

/**
 * Create N Vars
 * create_n_vars(+N, -Vars)
 * Creates a list with N variables
 *
 * N -> Number of vars
 * Vars -> List of vars
 */
create_n_vars(0, []) :- !.
create_n_vars(N, [New | Vars]) :-
    Next is N-1,
    create_n_vars(Next, Vars).