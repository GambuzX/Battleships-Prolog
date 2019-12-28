:- use_module(library(clpfd)).
:- use_module(library(lists)).

:- include('display.pl').
:- include('input.pl').
:- include('files.pl').

/**
 * Battleships
 * battleships(+Path)
 * Main function of the puzzle
 *
 * Path -> Path to this file (Files to be used should be inside a folder files)  
 */
battleships(Path) :-
    display_game_name,
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

/**
 * Choose menu option
 * choose_menu_option(+Option)
 *
 * Option -> Selected option:
 *              1- Solve board;
 *              2- Generate board;
 *              3- Exit.
 */
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

/**
 * Get File Path
 * get_file_path(+RelativePath, -AbsolutePath)
 * Gets the absolute path to file given a relative path from the main file
 *
 * RelativePath -> The relative path from the main file
 * AbsolutePath -> The absolute file to the selected file
 */
get_file_path(RelPath, AbsPath) :-
    path(P),
    atom_concat(P, RelPath, AbsPath), !.

/**
 * Choose Board
 * choose_board(+Option)
 * Chooses the board that will be solved
 *
 * Option -> The selected option from the menu
 *              1..5- Default files;
 *              6- Other file created by our generator;
 *              7- Go back to the menu.
 */
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
    ships not touching each other - y
    numbers in lines and cols - n
    water blocks - n
    get answer from result of labeling - n
    match already existing ships - n
    generate boards - n
    read from files - n
    generalize - n
    optimizations - n


        Since geost shapes objects from bottom to top, we decided to invert
    the board so that the y increases upwards. As such, the values for the sum
    of the ships on the rows are inverted.
*/
solve_battleships(ShipsShapes, Positions) :-
    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10],
    Positions = [
        X1, X2, X3, X4, X5, X6, X7, X8, X9, X10,
        Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8, Y9, Y10
    ],

    HorizontalCounts = [4, 1, 3, 0, 3, 0, 4, 0, 2, 3],
    VerticalCounts = [1, 4, 1, 0, 4, 4, 1, 3, 1, 1],

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
        sbox(4, [0,0], [1, 3]),
        sbox(5, [0,0], [3, 1]),
        sbox(6, [0,0], [1, 4]),
        sbox(7, [0,0], [4, 1])
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
        
        card(quantified variable, list of terms, lower bound, upper bound, fol)
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
        (forall(Obj1, objects([1,2,3,4,5,6,7,8,9,10]), % TODO these ids must come from outside and not be hardcoded
            forall(Obj2, objects([1,2,3,4,5,6,7,8,9,10]),
                % if different objects, must be apart 1 unit
                (Obj2^oid #>= Obj1^oid) #\/ apart(Obj1, Obj2))))
    ],
    
    geost(Ships, Shapes, Options, Rules),
    %force_horizontal_ships_counts(1, HorizontalCounts, Ships, Shapes),
    append(Positions, ShipsShapes, AllVars),
    labeling([ffc, median], AllVars),
    write(ShipsShapes),
    write(Positions).

/*
    Find shape from list Shapes with ID equal to ShapeID
*/
find_shape(ShapeID, [CurrShape | Rest], CurrShape) :-
    sbox(CurrShapeID, _, _) = CurrShape,
    ShapeID #= CurrShapeID.

find_shape(ShapeID, [CurrShape | Rest], Res) :-
    sbox(ShapeID2, _, _) = CurrShape,
    ShapeID #\= ShapeID2,
    find_shape(ShapeID, Rest, Res).

/*
    Count number of ships in a row
*/
count_ships_in_row(_, [], _, 0).
count_ships_in_row(Row, [object(_, CurrShapeID, [_, Y]) | RestShips], Shapes, Count) :-    
    
    find_shape(CurrShapeID, Shapes, CurrShape),
    sbox(_, _, [_, Height]) = CurrShape,

    EndY #= Y + Height,

    (Y #=< Row #/\ EndY #>= Row) #<=> Matched,
    Count #= NextCount + Matched,
    count_ships_in_row(Row, RestShips, Shapes, NextCount).

/*
    Restrict number of ships per row to the given values
*/
force_horizontal_ships_counts(I, Vals, _, _) :-
    length(Vals, L),
    I > L.
force_horizontal_ships_counts(Iter, HorizontalCounts, Ships, Shapes) :-
    length(HorizontalCounts, L),
    Iter =< L,

    % get curr target value
    nth1(Iter, HorizontalCounts, CurrTarget),

    % force value to be the target
    count_ships_in_row(Iter, Ships, Shapes, CurrCount),
    CurrCount #= CurrTarget,    
    
    Next is Iter+1,
    force_horizontal_ships_counts(Next, HorizontalCounts, Ships, Shapes).
