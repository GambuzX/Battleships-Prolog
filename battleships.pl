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
    display_board(Board, Row/Column, RowVal, ColVal),
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

test :-
    HorizontalCounts = [4, 1, 3, 0, 3, 0, 4, 0, 2, 3],
    VerticalCounts = [1, 4, 1, 0, 4, 4, 1, 3, 1, 1],
    WaterBlocks = [5/5, 1/7],
    solve_battleships(10/10, 10, [], HorizontalCounts, VerticalCounts).



/*
    TODO

    assure count of each shape - y
    ships not touching each other - y
    numbers in lines and cols - y
    water blocks - n
    get answer from result of labeling - n
    match already existing ships - n
    generate boards - n
    read from files - n
    generalize - y
    variable number of ships - n
    optimizations - n
    display result - n


        Since geost shapes objects from bottom to top, we decided to invert
    the board so that the y increases upwards. As such, the values for the sum
    of the ships on the rows are inverted.
    The board should be imagined with increasing y and figures growing upwards.
*/
solve_battleships(Rows/Columns, NShips, Board, HorizontalCounts, VerticalCounts) :-

    ShipsShapes = [S1, S2, S3, S4, S5, S6, S7, S8, S9, S10],
    X_Coords = [X1, X2, X3, X4, X5, X6, X7, X8, X9, X10],
    Y_Coords = [Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8, Y9, Y10],

    % 1 indexed!!!!
    domain(X_Coords, 1, Columns),
    domain(Y_Coords, 1, Rows),

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
    WaterBlocks = [
        object(11, 1, [5, 5]),
        object(12, 1, [1, 7])
    ],
    getObjectsIDs(Ships, ShipsIDs),
    getObjectsIDs(WaterBlocks, WaterBlocksIDs),

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

    Bounding_box_x is Columns+1,
    Bounding_box_y is Rows+1,
    Options = [
        /*
            limit all coordinates of the objects to be in range [1,10]
            geost only guarantees that the object origin is inside the specified domain
        */
        bounding_box([1, 1], [Bounding_box_x, Bounding_box_y])
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

        (tooclose(Obj1, Obj2, Shape1, Shape2, Dist, Dim) --->
            end(Obj1, Shape1, Dim) + Dist #> origin(Obj2, Shape2, Dim) #/\
            end(Obj2, Shape2, Dim) + Dist #> origin(Obj1, Shape1, Dim)),

        % assure objects O1 and O2 are apart, by at least Dist units
        (apart(Obj1, Obj2, Dist) --->
            forall(Shape1, sboxes([Obj1^sid]), % shape boxes of object O1, could be more than 1
                forall(Shape2, sboxes([Obj2^sid]),% shape boxes of object O2
                    #\ tooclose(Obj1, Obj2, Shape1, Shape2, Dist, 1) #\/ % check horizontally
                    #\ tooclose(Obj1, Obj2, Shape1, Shape2, Dist, 2)))), % check vertically

        % for all combinations of different objects
        (forall(Obj1, objects(ShipsIDs), % TODO these ids must come from outside and not be hardcoded
            forall(Obj2, objects(ShipsIDs),
                % if different objects, must be apart 1 unit
                (Obj2^oid #>= Obj1^oid) #\/ apart(Obj1, Obj2, 1)))),

        (forall(Obj, objects(ShipsIDs),
            forall(WaterBlock, objects(WaterBlocksIDs),
                apart(Obj, WaterBlock, 0))))
    ],
    
    append([Ships, WaterBlocks], AllObjects),
    geost(AllObjects, Shapes, Options, Rules),
    force_horizontal_ships_counts(1, HorizontalCounts, Ships),
    force_vertical_ships_counts(1, VerticalCounts, Ships),

    append([ShipsShapes, X_Coords, Y_Coords], AllVars),
    labeling([ffc, median], AllVars),
    write(ShipsShapes),
    write(X_Coords),
    write(Y_Coords).

/*
create_ships_shapes(I, N, []]) :-
    Iter > N.
create_ships_shapes(Iter, NShips, [NewShape | RestShapes]) :-
    Iter =< N,
    Shape1 = 1,
    Shape2 = 1,
    domain([NewShape], Shape1, Shape2),
    Next is Iter+1,
    create_ships_shapes(Next, NShips, RestShapes).
*/


/* Collect the IDs of the objects in a list */
getObjectsIDs([], []).
getObjectsIDs([object(ID, _, _) | Rest], [ID | RestIDs]) :-
    getObjectsIDs(Rest, RestIDs).


apply_shape_size_restrictions(ShapeID, Width, Height) :-
    (ShapeID #= 1 #/\ Width #= 1 #/\ Height #= 1) #\/
    (ShapeID #= 2 #/\ Width #= 1 #/\ Height #= 2) #\/
    (ShapeID #= 3 #/\ Width #= 2 #/\ Height #= 1) #\/
    (ShapeID #= 4 #/\ Width #= 1 #/\ Height #= 3) #\/
    (ShapeID #= 5 #/\ Width #= 3 #/\ Height #= 1) #\/
    (ShapeID #= 6 #/\ Width #= 1 #/\ Height #= 4) #\/
    (ShapeID #= 7 #/\ Width #= 4 #/\ Height #= 1).

/*
    Count number of ships in a row
*/
count_ships_in_row(_, [], 0).
count_ships_in_row(Row, [object(_, CurrShapeID, [_, Y]) | RestShips], Count) :-  
    apply_shape_size_restrictions(CurrShapeID, Width, Height),
    EndY #= Y + Height - 1,

    (Y #=< Row #/\ EndY #>= Row) #<=> Matched,
    Count #= NextCount + Matched * Width,
    count_ships_in_row(Row, RestShips, NextCount).

/*
    Restrict number of ships per row to the given values
*/
force_horizontal_ships_counts(I, Vals, _) :-
    length(Vals, L),
    I > L.
force_horizontal_ships_counts(Iter, HorizontalCounts, Ships) :-
    length(HorizontalCounts, L),
    Iter =< L,

    % get curr target value
    nth1(Iter, HorizontalCounts, CurrTarget),

    % force value to be the target
    count_ships_in_row(Iter, Ships, CurrCount),
    CurrCount #= CurrTarget,    
    
    Next is Iter+1,
    force_horizontal_ships_counts(Next, HorizontalCounts, Ships).

/*
    Count number of ships in a column
*/
count_ships_in_col(_, [], 0).
count_ships_in_col(Col, [object(_, CurrShapeID, [X, _]) | RestShips], Count) :-   
    apply_shape_size_restrictions(CurrShapeID, Width, Height),
    EndX #= X + Width - 1,

    (X #=< Col #/\ EndX #>= Col) #<=> Matched,
    Count #= NextCount + Matched * Height,
    count_ships_in_col(Col, RestShips, NextCount).

/*
    Restrict number of ships per row to the given values
*/
force_vertical_ships_counts(I, Vals, _) :-
    length(Vals, L),
    I > L.
force_vertical_ships_counts(Iter, VerticalCounts, Ships) :-
    length(VerticalCounts, L),
    Iter =< L,

    % get curr target value
    nth1(Iter, VerticalCounts, CurrTarget),

    % force value to be the target
    count_ships_in_col(Iter, Ships, CurrCount),
    CurrCount #= CurrTarget,    
    
    Next is Iter+1,
    force_vertical_ships_counts(Next, VerticalCounts, Ships).