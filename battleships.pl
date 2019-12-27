:-use_module(library(clpfd)).

:-include('display.pl').
:-include('input.pl').
:-include('files.pl').

/**
 * Battleships
 * battleships(+Path)
 * Main function of the puzzle
 *
 * Path -> Path to this file (Files to be used should be inside a folder files)  
 */
battleships(Path) :-
    asserta(path(Path)), !,
    battleships_menu, !,
    retract(path(_)).

/**
 * Battleships Menu
 * battleships_menu
 * Shows the puzzle menu and choose the selected option
 */
battleships_menu :-
    repeat,
        (
            display_menu_options,
            read_menu_option(Option),
            choose_menu_option(Option), !;

            error_msg('Invalid option!')
        ).

choose_menu_option(1) :-
    repeat,
        (
            display_choose_board,
            read_board_option(Option),
            choose_board(Option), !;

            error_msg('Invalid option')
        ).

choose_menu_option(2).
choose_menu_option(3).

get_file_path(RelPath, AbsPath) :-
    path(P),
    atom_concat(P, RelPath, AbsPath), !.

choose_board(1) :-
    get_file_path('files/board_1.txt', FileName),
    read(FileName, Row/Column, Board, RowVal, ColVal),
    battleships_menu, !.

choose_board(2) :-
    get_file_path('files/board_2.txt', FileName),
    read(FileName, Row/Column, Board, RowVal, ColVal),
    battleships_menu, !.

choose_board(3) :-
    get_file_path('files/board_3.txt', FileName),
    read(FileName, Row/Column, Board, RowVal, ColVal),
    battleships_menu, !.

choose_board(4) :-
    get_file_path('files/board_4.txt', FileName),
    read(FileName, Row/Column, Board, RowVal, ColVal),
    battleships_menu, !.

choose_board(5) :-
    get_file_path('files/board_5.txt', FileName),
    read(FileName, Row/Column, Board, RowVal, ColVal),
    battleships_menu, !.

choose_board(6).

choose_board(7) :-
    battleships_menu, !.


/*
    TODO

    assure count of each shape - y
    ships not touching each other - n
    number in lines and cols - n
    water blocks - n
    get answer from result of labeling - n
    match already existing ships - n
    generate boards - n
    read from files - n
    generalize - n

*/
solve(ShipsShapes, Positions) :-
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10],
    Positions = [
        X1, X2, X3, X4, X5, X6, X7, X8, X9, X10,
        Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8, Y9, Y10
    ],

    % 1 indexed!!!!
    domain(Positions, 1, 10),

    domain([S1, S2, S3, S4], 1, 1),
    domain([S5, S6, S7], 2, 3),
    domain([S8, S9], 4, 5),
    domain([S10], 6, 7),

    Ships = [
        object(1, S1, [X1, Y1]),
        object(2, S2, [X2, Y2]),
        object(3, S3, [X3, Y3]),
        object(4, S4, [X4, Y4]),
        object(5, S5, [X5, Y5]),
        object(6, S6, [X6, Y6]),
        object(7, S7, [X7, Y7]),
        object(8, S8, [X8, Y8]),
        object(9, S9, [X9, Y9]),
        object(10, S10, [X10, Y10])
    ],

    % horizontal and vertical shapes for each ship size
    Shapes = [
        sbox(1, [0,0], [1, 1]),
        sbox(2, [0,0], [1, 2]),
        sbox(3, [0,0], [2, 1]),
        sbox(4, [0,0], [3, 1]),
        sbox(5, [0,0], [1, 3]),
        sbox(6, [0,0], [4, 1]),
        sbox(7, [0,0], [1, 4])
    ],


    geost(Ships, Shapes, 
        % Options
        [
            /*
                limit all coordinates of the objects to be in range [1,10]
                geost only guarantees that the object origin is inside the specified domain
            */
            bounding_box([1, 1], [11, 11])
        ],

        /*
        Geost Rules (https://web.imt-atlantique.fr/x-info/ppc/bib/pub/carlsson-al-CP-2008.pdf)

        k is the dimension, in this case 2.
        Below, d means the dimension to extract value.

        Shapes' properties (integers):
            - s.sid : shape id
            - s.t[d] : shift offset (1 <= d <= k)
            - s.l[d] : sizes (s.l[d] > 0 and 1 <= d <= k)

        Objects' properties:
            - o.oid : unique object id (integer)
            - o.sid : shape id (integer if fixed shape, or domain variable for polymorphic objects)
            - o.x[d] : origin (1 <= d <= k)
        

        */
        [ 
            /* sum of origin value with shape offset in dimension D*/
            (origin(O1,S1,D) ---> O1^x(D)+S1^t(D))),

            /* sum of origin value with shape offset and size in dimension D */
            (end(O1,S1,D) ---> O1^x(D)+S1^t(D)+S1^l(D)),

            /*
                Check if objects are near by 2 units
                O1 -> Object 1
                O2 -> Object 2
                S1 -> Shape box of object 1
                S2 -> Shape box of object 2
                D -> Dimension
            */
            (tooclose(O1,O2,S1,S2,D) --->
                end(O1,S1,D)+2 #> origin(O2,S2,D) #/\
                end(O2,S2,D)+2 #> origin(O1,S1,D)),

            % assure objects O1 and O2 are apart at least 2 units
            (apart(O1,O2) --->
                forall(S1,sboxes([O1^sid]), % shape box of object O1
                    forall(S2,sboxes([O2^sid]), % shape box of object O2
                        #\ tooclose(O1,O2,S1,S2,1) #\/ % check horizontally
                        #\ tooclose(O1,O2,S1,S2,2)))), % check vertically

            % for all combinations of different objects
            (forall(O1,objects([1,2,3]),
                forall(O2,objects([4,5,6]), apart(O1,O2))))
        ]
    ),
    append(ShipsShapes, Positions, AllVars),
    labeling([], AllVars),
    write(ShipsShapes),
    write(Positions).