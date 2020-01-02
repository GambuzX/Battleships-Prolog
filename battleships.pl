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

choose_menu_option(2) :-
    generate_board_option.

choose_menu_option(3).

/**
 * Generate Board Option
 * generate_board_option
 * Generate Board Option
 */
 generate_board_option :-
    write('GENERATE BOARD'), nl, nl,
    write('Insert the name of the output file (please end the name with a \'.\'): '),
    read(FileName), !,
    change_file_name(FileName, FileRelPath),
    get_file_path(FileRelPath, FilePath), !,
    read_board_size(NumRows, NumColumns),
    generate_board(NumRows, NumColumns, Board, RowValues, ColumnValues),
    write(FilePath, NumRows/NumColumns, Board, RowValues, ColumnValues), !.

generate_board_option.

/**
 * Generate Board
 * generate_board(+NumRows, +NumColumns)
 * Generate Board
 *
 * NumRows -> Number of board rows
 * NumColumns -> Number of board columns
 */
generate_board(NumRows, NumColumns).

/**
 * Add files directory and .txt extension
 * change_file_name(Name, RelPath)
 *
 * Name -> Inserted name
 * NewName -> Name with .txt extension
 */
change_file_name(Name, RelPath) :-
    atom_concat(Name, '.txt', NewName),
    atom_concat('files/', NewName, RelPath).

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
    get_battleships_board(FileName),
    battleships_menu, !.

choose_board(2) :-
    get_file_path('files/board_2.txt', FileName),
    get_battleships_board(FileName),
    battleships_menu, !.

choose_board(3) :-
    get_file_path('files/board_3.txt', FileName),
    get_battleships_board(FileName),
    battleships_menu, !.

choose_board(4) :-
    get_file_path('files/board_4.txt', FileName),
    get_battleships_board(FileName),
    battleships_menu, !.

choose_board(5) :-
    get_file_path('files/board_5.txt', FileName),
    get_battleships_board(FileName),
    battleships_menu, !.

choose_board(6).

choose_board(_) :-
    battleships_menu, !.

test :-
    HorizontalCounts = [3, 2, 0, 4, 0, 3, 0, 3, 1, 4],
    VerticalCounts = [1, 4, 1, 0, 4, 4, 1, 3, 1, 1],
    WaterBlocks = [5/6, 1/4], % get water blocks from board
    RequiredPositions = [5/4],
    solve_battleships(10/10, 10, WaterBlocks, RequiredPositions, HorizontalCounts, VerticalCounts).

/**
 * Get Battleships Board
 * get_battleships_board(+FileName)
 *
 * FileName -> Absolute path to the file
 */
get_battleships_board(FileName) :-
    read(FileName, Row/Column, Board, RowVal, ColVal),
    display_board(Board, Row/Column, RowVal, ColVal),
    get_water_blocks(Board, WaterBlocks),
    get_ship_blocks(Board, RequiredBlocks),
    solve_battleships(Row/Column, _, WaterBlocks, RequiredBlocks, RowVal, ColVal).
   

/**
 * Get Water Blocks
 * get_water_blocks(+Board, -WaterBlocks)
 * Gets the water blocks
 * 
 * Board -> Puzzle board
 * WaterBlocks -> List with the positions of the water blocks 
 */
get_water_blocks(Board, WaterBlocks) :-
    get_blocks(Board, w, 1, WaterBlocks), !.

/**
 * Get Ship Blocks
 * get_ship_blocks(+Board, -ShipBlocks)
 * Gets the ship blocks
 * 
 * Board -> Puzzle board
 * ShipBlocks -> List with the positions of the ship blocks 
 */
get_ship_blocks(Board, ShipBlocks) :-
    get_blocks(Board, s, 1, ShipBlocks), !.

/**
 * Get Blocks
 * get_blocks(+Board, +Character, +RowNumber, -Blocks)
 * Gets the blocks with the specified character
 * 
 * Board -> Puzzle board
 * Character -> Character to search
 * RowNumber -> Current row number [1, MaxRows]
 * Blocks -> List with the positions of the blocks 
 */
get_blocks([], _, _, []) :- !. 

get_blocks([FirstRow|OtherRows], Char, Row, Blocks) :-
    NextRow is Row + 1,
    get_blocks(OtherRows, Char, NextRow, NextBlocks),
    get_row_blocks(FirstRow, Char, Row, 1, RowBlocks),
    append(RowBlocks, NextBlocks, Blocks), !.

/**
 * Get Row Blocks
 * get_row_blocks(+Row, +Character, +RowNumber, +ColumnNumber, -Blocks)
 * Gets the blocks in a row with the specified character
 * 
 * Row -> Puzzle board row
 * Character -> Character to search
 * RowNumber -> Current row number [1, MaxRows]
 * ColumnNumber -> Current column number [1, MaxColumns]
 * Blocks -> List with the positions of the blocks 
 */
get_row_blocks([], _, _, _, []) :- !.

get_row_blocks([Pos|OtherPos], Char, Row, Column, Blocks) :-
    Pos = Char,
    NextColumn is Column + 1,
    get_row_blocks(OtherPos, Char, Row, NextColumn, NextBlocks),
    append([Column/Row], NextBlocks, Blocks),!.

get_row_blocks([Pos|OtherPos], Char, Row, Column, Blocks) :-
    Pos \= Char,
    NextColumn is Column + 1,
    get_row_blocks(OtherPos, Char, Row, NextColumn, Blocks), !.

/*
    TODO

    assure count of each shape - y
    ships not touching each other - y
    numbers in lines and cols - y
    water blocks - y
    match already existing ships - y
    generalize - y
    get answer from result of labeling - y
    display result - n
    optimizations - n +-
    generate boards - n
    read from files - n
    variable number of ships - n


        Since geost shapes objects from bottom to top, we decided to invert
    the board so that the y increases upwards. As such, the values for the sum
    of the ships on the rows are inverted.
    The board should be imagined with increasing y and figures growing upwards.
*/
solve_battleships(Rows/Columns, NShips, WaterBlocksL, RequiredPosL, HorizontalCounts, VerticalCounts) :-

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

    StartObjID = 1,
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
    LastAssignedID = 10,
    createWaterBlocks(LastAssignedID, WaterBlocksL, WaterBlocks, LastAssignedID2),

    % collect IDs of objects to use in geost Rules
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
        bounding_box([1, 1], [Bounding_box_x, Bounding_box_y]),

        
        % eliminate symmetries in answers
        lex([1,2,3,4]),
        lex([5,6,7]),
        lex([8,9])
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

        (tooclose(Obj1, Obj2, Shape1, Shape2, Dist, Dim) --->
            end(Obj1, Shape1, Dim) + Dist #> origin(Obj2, Shape2, Dim) #/\
            end(Obj2, Shape2, Dim) + Dist #> origin(Obj1, Shape1, Dim)),

        % assure objects O1 and O2 are apart, by at least Dist units
        (apart(Obj1, Obj2, Dist) --->
            forall(Shape1, sboxes([Obj1^sid]), % shape boxes of object O1, could be more than 1
                forall(Shape2, sboxes([Obj2^sid]),% shape boxes of object O2
                    #\ tooclose(Obj1, Obj2, Shape1, Shape2, Dist, 1) #\/ % check horizontally
                    #\ tooclose(Obj1, Obj2, Shape1, Shape2, Dist, 2)))), % check vertically

        (dim_intersects(Obj, Shape, Coord, Dim) --->
            origin(Obj, Shape, Dim) #=< Coord #/\ Coord #=< end(Obj, Shape, Dim)
        ),

        % checks if Object intersects given position
        (intersect(Obj, X/Y) --->
            forall(Shape, sboxes([Obj^sid]),
                dim_intersects(Obj, Shape, X, 0) #/\
                dim_intersects(Obj, Shape, Y, 1))),

        % for all combinations of different objects
        (forall(Obj1, objects(ShipsIDs), % TODO these ids must come from outside and not be hardcoded
            forall(Obj2, objects(ShipsIDs),
                % if different objects, must be apart 1 unit
                (Obj2^oid #>= Obj1^oid) #\/ apart(Obj1, Obj2, 1)))),

        (forall(Obj, objects(ShipsIDs),
            forall(WaterBlock, objects(WaterBlocksIDs),
                % must not intersect. apart by 0 units means touching each other but not intersecting
                apart(Obj, WaterBlock, 0)))),

        (forall(Req, RequiredPositions, 
            exists(Obj, objects(ShipsIDs), intersects(Obj, Req))))
    ],
    
    append([Ships, WaterBlocks], AllObjects),
    geost(AllObjects, Shapes, Options, Rules),
    force_horizontal_ships_counts(1, HorizontalCounts, Ships),
    force_vertical_ships_counts(1, VerticalCounts, Ships),

    append([ShipsShapes, X_Coords, Y_Coords], AllVars),
    labeling([ffc, median], AllVars),

    create_board(Rows/Columns, Ships, Shapes, WaterBlocksL, FinalBoard),
    display_board(FinalBoard, Rows/Columns, HorizontalCounts, VerticalCounts).

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

createWaterBlocks(ID, [], [], ID).
createWaterBlocks(LastAssignedID, [ X/Y | WaterBlocksL], [ object(CurrID, 1, [X, Y]) | WaterBlocks], LastAssignedID2) :-
    CurrID is LastAssignedID + 1,
    createWaterBlocks(CurrID, WaterBlocksL, WaterBlocks, LastAssignedID2).



/* Collect the IDs of the objects in a list */
getObjectsIDs([], []).
getObjectsIDs([object(ID, _, _) | Rest], [ID | RestIDs]) :-
    getObjectsIDs(Rest, RestIDs).

% second point is farther from origin, or at same distance but with higher X
% replaced by 'lex' in geost Options
eliminate_coords_symmetry(X1, Y1, X2, Y2) :-
    (X1 + Y1 #< X2 + Y2) #\/ (X1 + Y1 #= X2 + Y2 #/\ X1 #=< X2).


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

create_board(Rows/Cols, Ships, Shapes, WaterBlocks, NewBoard) :-
    length(Board, Rows),
    assign_rows_length(Board, Cols),
    draw_ships(Board, Ships, Shapes),
    reverse(Board, NewBoard),
    draw_water_blocks(NewBoard, WaterBlocks),
    fill_missing(NewBoard).
    
assign_rows_length([], _) :- !.
assign_rows_length([Row | Rest], Cols) :-
    length(Row, Cols),
    assign_rows_length(Rest, Cols).

get_shape(ShapeID, [Shape | _], Shape) :-
    sbox(CurrShapeID, _, _) = Shape,
    ShapeID = CurrShapeID.

get_shape(ShapeID, [Shape | Rest], TargetShape) :-
    sbox(CurrShapeID, _, _) = Shape,
    ShapeID \= CurrShapeID,
    get_shape(ShapeID, Rest, TargetShape).

% draw ships in the board with 's'
draw_ships(_, [], _) :- !.
draw_ships(Board, [object(_, ShapeID, [X, Y]) | Rest], Shapes) :-
    get_shape(ShapeID, Shapes, Shape),
    sbox(_, _, [Sx, Sy]) = Shape,
    (
        Sx = 1, draw_ship_vertical(Board, X/Y, Sy);
        Sy = 1, draw_ship_horizontal(Board, X/Y, Sx)
    ), !,
    draw_ships(Board, Rest, Shapes).

draw_ship_vertical(_, _, 0) :- !.
draw_ship_vertical(Board, X/Y, Height) :-
    nth1(Y, Board, Row),
    nth1(X, Row, s),
    NextY is Y+1,
    NextHeight is Height-1,
    draw_ship_vertical(Board, X/NextY, NextHeight).

draw_ship_horizontal(_, _, 0) :- !.
draw_ship_horizontal(Board, X/Y, Width) :-
    nth1(Y, Board, Row),
    nth1(X, Row, s),
    NextX is X+1,
    NextWidth is Width-1,
    draw_ship_horizontal(Board, NextX/Y, NextWidth).

% draw water blocks in the board, given by coords X/Y, as 'w'
draw_water_blocks(_, []) :- !.
draw_water_blocks(Board, [X/Y | Rest]) :-
    nth1(Y, Board, Row),
    nth1(X, Row, w),
    draw_water_blocks(Board, Rest).

% assign remaining variables in board to 'e', empty
fill_missing([]) :- !.
fill_missing([Row | Rest]) :-
    fill_missing_row(Row),
    fill_missing(Rest).

fill_missing_row([]) :- !.
fill_missing_row([Ele | Rest]) :-
    (
        nonvar(Ele);
        Ele = e
    ), !,
    fill_missing_row(Rest).