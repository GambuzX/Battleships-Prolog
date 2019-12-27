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

    Options = [
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
    Rules = [ 
        /* sum of origin value with shape offset in dimension D*/
        (origin(Obj, Shape, Dim) ---> Obj^x(Dim) + Shape^t(Dim)),

        /* sum of origin value with shape offset and size in dimension D */
        (end(Obj, Shape, Dim) ---> Obj^x(Dim) + Shape^t(Dim) + Shape^l(Dim)),

        (tooclose(Obj1, Obj2, Shape1, Shape2, Dim) --->
            end(Obj1, Shape1, Dim) + 1 #> origin(Obj2, Shape2, Dim) #/\
            end(Obj2, Shape2, Dim) + 1 #> origin(Obj1, Shape1, Dim)),

        % assure objects O1 and O2 are apart at least 1 unit
        (apart(Obj1, Obj2) --->
            forall(Shape1, sboxes([Obj1^sid]), % shape boxes of object O1, could be more than 1
                forall(Shape2, sboxes([Obj2^sid]),% shape boxes of object O2
                    #\ tooclose(Obj1, Obj2, Shape1, Shape2, 1) #\/ % check horizontally
                    #\ tooclose(Obj1, Obj2, Shape1, Shape2, 2)))), % check vertically

        % for all combinations of different objects
        (forall(Obj1, objects([1,2,3,4,5,6,7,8,9,10]),
            forall(Obj2, objects([1,2,3,4,5,6,7,8,9,10]),
                % if different objects, must be apart 1 unit
                (Obj1^oid #= Obj2^oid) #\/ apart(Obj1, Obj2))))
    ],


    geost(Ships, Shapes, Options, Rules),
    append(ShipsShapes, Positions, AllVars),
    labeling([], AllVars),
    write(ShipsShapes),
    write(Positions).