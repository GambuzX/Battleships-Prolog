:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(random)).

:- include('display.pl').
:- include('input.pl').
:- include('files.pl').
:- include('ship_fleet.pl').

/**
 * Battleships
 * battleships
 * Main function of the puzzle
 * 
 * WARNING: Change the working directory to the directory where this file is so that the program can run properly.
 */
battleships :-
    battleships(''), !.

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
    generate_board_option,
    battleships_menu, !.
        
choose_menu_option(3).

/**
 * Generate Board Option
 * generate_board_option
 * Generate Board Option
 */
 generate_board_option :-
    display_generate_board,

    % read the filename
    read(FileName), !,

    % change FileName to files/[FileName].txt 
    change_file_name(FileName, FileRelPath),

    % get the absolute path to the file
    get_file_path(FileRelPath, FilePath), !,
    
    % read the board size
    read_board_size(NumRows, NumColumns),

    % read number of ships
    read_num_ships(NumShips),
    
    write('Placing ships in the board...'), nl,
    
    % generate board with all the ships
    reset_timer,
    repeat,
        generate_board(NumRows, NumColumns, NumShips, Board), !,

    % count values in the rows
    length(RowValues, NumRows),
    get_row_values(Board, RowVal),
    reverse(RowVal, RowValues),

    % count values in the columns
    length(ColumnValues, NumColumns),
    get_column_values(Board, 1, ColumnValues), !,

    % create new board
    create_new_board(Board, NumRows, NumColumns, NewBoard),

    % display the generated board
    display_board(NewBoard, NumRows/NumColumns, RowValues, ColumnValues),
    
    % write the board to the file
    write(FilePath, NumShips, NumRows/NumColumns, NewBoard, RowValues, ColumnValues), !.

generate_board_option.

/**
 * Create New Board
 * create_new_board(+Board, +NumRows, +NumColumns, -NewBoard)
 * Creates a new board
 *
 * Board -> The generated board
 * NumRows -> Number of rows
 * NumColumns -> Number of columns
 * NewBoard -> New generated board
 */
create_new_board(Board, NumRows, NumColumns, NewBoard) :-
    reverse(Board, RevBoard),

    % get all types of blocks to separate lists
    get_blocks(RevBoard, e, NumRows, EmptyBlocks),
    get_blocks(RevBoard, s, NumRows, SubmarineBlocks),
    get_blocks(RevBoard, m, NumRows, MiddleBlocks),
    get_blocks(RevBoard, l, NumRows, LeftBlocks),
    get_blocks(RevBoard, b, NumRows, BottomBlocks),
    get_blocks(RevBoard, r, NumRows, RightBlocks),
    get_blocks(RevBoard, t, NumRows, TopBlocks),

    % ask for hints of all types
    select_random_blocks(EmptyBlocks, 'water', WaterBlocks),
    select_random_blocks(SubmarineBlocks, 'hints for submarines', SelectedSubmarineBlocks),
    select_random_blocks(MiddleBlocks, 'hints for middle of ships', SelectedMiddleBlocks),
    select_random_blocks(LeftBlocks, 'hints for left edge of ships', SelectedLeftBlocks),
    select_random_blocks(BottomBlocks, 'hints for bottom edge of ships', SelectedBottomBlocks),
    select_random_blocks(RightBlocks, 'hints for right edge of ships', SelectedRightBlocks),
    select_random_blocks(TopBlocks, 'hints for top edge of ships', SelectedTopBlocks),

    length(NewBoard, NumRows),
    assign_rows_length(NewBoard, NumColumns),
    
    % draw all blocks in new board
    draw_blocks_in_board(NewBoard, WaterBlocks, w),
    draw_blocks_in_board(NewBoard, SelectedSubmarineBlocks, s),
    draw_blocks_in_board(NewBoard, SelectedMiddleBlocks, m),
    draw_blocks_in_board(NewBoard, SelectedLeftBlocks, l),
    draw_blocks_in_board(NewBoard, SelectedBottomBlocks, b),
    draw_blocks_in_board(NewBoard, SelectedRightBlocks, r),
    draw_blocks_in_board(NewBoard, SelectedTopBlocks, t),
   
    fill_missing(NewBoard), !.

/**
 * Select Random Water Blocks
 * select_random_water_blocks(+Blocks, -WaterBlocks)
 * Selects random water blocks
 *
 * Blocks -> Initial blocks
 * WaterBlocks -> Selected water blocks
 */
select_random_water_blocks(Blocks, WaterBlocks) :-
    select_random_blocks(Blocks, 'water', WaterBlocks), !.

/**
 * Select Random Blocks
 * select_random_blocks(+Blocks, +TypeOfBlocks, -NewBlocks)
 * Gets the NumBlocks (number of blocks) from the input and selects NumBlocks random blocks
 *
 * Blocks -> Initial blocks
 * TypeOfBlocks -> String with the type of blocks (used in the initial message)
 * NewBlocks -> Selected blocks
 */
select_random_blocks(Blocks, TypeOfBlocks, NewBlocks) :-
    length(Blocks, Max),
    write('Select number of '), write(TypeOfBlocks), 
    write(' blocks (Max='), write(Max), 
    write('; please end the name with a \'.\'): '),
    repeat,
        (
            read(NumBlocks),
            get_code(_), % Return code
            NumBlocks >= 0,
            NumBlocks =< Max, !;

            error_msg('Invalid number of blocks')
        ),

    select_blocks(Blocks, NumBlocks, NewBlocks), !.

/**
 * Select Blocks
 * selec_blocks(+Blocks, +NumBlocks, -NewBlocks)
 * Selects NumBlocks blocks from Blocks 
 *
 * Blocks -> Initial blocks
 * NumBlocks -> Number of blocks to select
 * NewBlocks -> Selected blocks
 */
select_blocks(_, 0, []) :- !.

select_blocks(Blocks, NumBlocks, NewBlocks) :-
    random_select(Block, Blocks, OtherBlocks),
    NextNum is NumBlocks - 1,
    select_blocks(OtherBlocks, NextNum, OtherNewBlocks),
    append([Block], OtherNewBlocks, NewBlocks), !.

/** 
 * Is ship block
 * is_ship_block(+Symbol)
 * Signals the blocks that represent ships.
 * 
 * Symbol -> symbol of the block.
 */
is_ship_block(s).
is_ship_block(m).
is_ship_block(l).
is_ship_block(b).
is_ship_block(r).
is_ship_block(t).

/** 
 * Get Row Values
 * get_row_values(+Board, ?RowValues)
 * Gets a list with the row values
 * 
 * Board -> The puzzle board
 * RowValues -> List with the sum of the ship parts in each row  
 */
get_row_values([], []) :- !.

get_row_values([Row|OtherRows], [RowValues|OtherRowsValues]) :-
    get_row_values(OtherRows, OtherRowsValues),
    count_row_parts(Row, RowValues), !.

/** 
 * Count Row Parts
 * count_row_parts(+Row, -RowValue)
 * Gets the value of a row
 * 
 * Row -> A puzzle row
 * RowValue -> Number of ship parts in the row  
 */
count_row_parts([], 0) :- !.

count_row_parts([Elem|Row], Value) :-
    is_ship_block(Elem),
    count_row_parts(Row, NewValue),
    Value is NewValue + 1, !.

count_row_parts([Elem|Row], Value) :-
    \+ is_ship_block(Elem),
    count_row_parts(Row, Value), !.

/** 
 * Get Column Values
 * get_column_values(+Board, +ColNumber, ?ColumnValues)
 * Gets a list with the column values
 * 
 * Board -> The puzzle board
 * ColNumber -> Current column nuber
 * ColumnValues -> List with the sum of the ship parts in each column  
 */
get_column_values(_, _, []) :- !.

get_column_values(Board, ColNumber, [ColVal|OtherColValues]) :-
    NextColNumber is ColNumber + 1,
    get_column_values(Board, NextColNumber, OtherColValues),
    count_column_parts(Board, ColNumber, ColVal), !.

/** 
 * Count Column Parts
 * count_column_parts(+Board, +ColNumber, -ColumnValue)
 * Gets the value of a column
 * 
 * Board -> The puzzle board
 * ColNumber -> Number of the current column
 * ColumnValue -> Number of ship parts in the column  
 */
count_column_parts([], _, 0) :- !.

count_column_parts([Row|OtherRows], ColNum, ColVal) :-
    nth1(ColNum, Row, Curr),
    is_ship_block(Curr),
    count_column_parts(OtherRows, ColNum, NextColVal),
    ColVal is NextColVal + 1, !.

count_column_parts([_|OtherRows], ColNum, ColVal) :-
    count_column_parts(OtherRows, ColNum, ColVal), !.

/**
 * Generate Board
 * generate_board(+Rows, +Columns, +NShips, -Board)
 * Generates a board with given dimensions, placing the 10 ship fleet.
 *
 * Rows -> Number of board rows
 * Columns -> Number of board columns
 * NShips -> Number of ships to be placed
 * Board -> Resulting board
 */
generate_board(Rows, Columns, NShips, Board) :-

    % gets the ship fleet depending on number of ships
    get_ship_fleet(NShips, ShipsShapes, X_Coords, Y_Coords, LexGroups),

    % 1 indexed!!!!
    domain(X_Coords, 1, Columns),
    domain(Y_Coords, 1, Rows),

    % initializes the list Ships
    createShipsList(0, X_Coords, Y_Coords, ShipsShapes, Ships, _),

    % collect IDs of objects to use in geost Rules
    getObjectsIDs(Ships, ShipsIDs),

    % horizontal and vertical shapes for each ship size
    Shapes = [
        sbox(1, [0,0], [1, 1]),
        sbox(2, [0,0], [1, 2]),
        sbox(3, [0,0], [2, 1]),
        sbox(4, [0,0], [1, 3]),
        sbox(5, [0,0], [3, 1]),
        sbox(6, [0,0], [1, 4]),
        sbox(7, [0,0], [4, 1]),
        sbox(8, [0,0], [1, 5]),
        sbox(9, [0,0], [5, 1])
    ],

    BaseOptions = [
        /*
            lift constraint in geost that objects should be non-overlapping.
            that behaviour will be handled by the Rules.
        */
        overlap(true)
    ],

    % eliminate symmetries in answers
    addLexOptions(BaseOptions, LexGroups, Options),

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

        % guarantee the whole ship fits inside the board
        (forall(Ship, objects(ShipsIDs),
            forall(Shape, sboxes([Ship^sid]),
                end(Ship, Shape, 1) #=< Columns + 1 #/\ % +1 because 'end' calculates ship edge, not position
                end(Ship, Shape, 2) #=< Rows + 1))),
                
        % for all combinations of different objects
        (forall(Obj1, objects(ShipsIDs),
            forall(Obj2, objects(ShipsIDs),
                % if different objects, must be apart 1 unit
                (Obj2^oid #>= Obj1^oid) #\/ apart(Obj1, Obj2, 1))))
    ],
    
    geost(Ships, Shapes, Options, Rules),

    append([ShipsShapes, X_Coords, Y_Coords], AllVars),

    labeling([ffc, value(select_random), time_out(5000, Flag)], AllVars),
    (
        Flag \= time_out;
        write('5 seconds timeout, trying again...'), nl, fail
    ), !,

    nl, write('Statistics:'), nl,
    fd_statistics,
    display_time,
    
    create_board(Rows/Columns, Ships, Shapes, [], Board).

/** 
 * Select Random
 * Chooses a random value to a variable
 */
select_random(Var, Rest, BB0, BB1):- 
    fd_set(Var, Set), fdset_to_list(Set, List),
    random_member(Value, List), 
    ( 
        first_bound(BB0, BB1), Var #= Value ;
        later_bound(BB0, BB1), Var #\= Value 
    ).

selRandom(ListOfVars, Var, Rest) :-
    random_select(Var, ListOfVars, Rest). 

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

choose_board(6) :-
    display_choose_input_board,

    % read the filename
    read(FileName), !,
    get_code(_), % Return code

    % change FileName to files/[FileName].txt 
    change_file_name(FileName, FileRelPath),

    % get the absolute path to the file
    get_file_path(FileRelPath, FilePath), !,

    get_battleships_board(FilePath),
    battleships_menu, !.

choose_board(_) :-
    battleships_menu, !.

/**
 * Get Battleships Board
 * get_battleships_board(+FileName)
 *
 * FileName -> Absolute path to the file
 */
get_battleships_board(FileName) :-
    read(FileName, NShips, Row/Column, Board, RowVal, ColVal),
    display_board(Board, Row/Column, RowVal, ColVal),
    length(Board, NumRows),
    get_blocks(Board, w, NumRows, WaterBlocks),
    get_blocks(Board, s, NumRows, SubmarineBlocks),
    get_blocks(Board, m, NumRows, MiddleBlocks),
    get_blocks(Board, l, NumRows, LeftBlocks),
    get_blocks(Board, b, NumRows, BottomBlocks),
    get_blocks(Board, r, NumRows, RightBlocks),
    get_blocks(Board, t, NumRows, TopBlocks),
    solve_battleships(Row/Column, NShips, WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, RowVal, ColVal).


/**
 * Get Water Blocks
 * get_water_blocks(+Board, -WaterBlocks)
 * Gets the water blocks
 * 
 * Board -> Puzzle board
 * WaterBlocks -> List with the positions of the water blocks 
 */
get_water_blocks(Board, WaterBlocks) :-
    length(Board, NumRows),
    get_blocks(Board, w, NumRows, WaterBlocks), !.

/**
 * Get Empty Blocks
 * get_empty_blocks(+Board, -EmptyBlocks)
 * Gets the empty blocks
 * 
 * Board -> Puzzle board
 * Empty -> List with the positions of the empty blocks 
 */
get_empty_blocks(Board, EmptyBlocks) :-
    length(Board, NumRows),
    get_blocks(Board, e, NumRows, EmptyBlocks), !.

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
    NextRow is Row - 1,
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


/**
 * Solve battleships
 * solve_battleships(+Dimensions, +NShips, +WaterBlocksList, +SubmarinesL, +MidPosL, +LeftPosL, +BottomPosL, +RightPosL, +TopPosL, +HorizontalCounts, +VerticalCounts)
 * Solves a battleships problem, given the provided input values.
 * Finds the position of all the ships in the board.
 *
 * Dimensions -> Size of the board, in format Rows/Columns
 * NShips -> Number of ships to be considered.
 * WaterBlocksList -> List of positions X/Y of Water blocks in the board
 * SubmarinesL -> Positions of required submarines, 1x1 ships
 * MidPosL -> Positions that must be the middle of a ship
 * LeftPosL -> Positions that must be the start of a horizontal ship
 * BottomPosL -> Positions that must be the start of a vertical ship
 * RightPosL -> Positions that must be the end of a horizontal ship
 * TopPosL -> Positions that must be the start of a vertical ship
 * HorizontalCounts -> List with the number of ship segments that must appear in each row
 * VerticalCounts -> List with the number of ship segments that must appear in each col
 */
solve_battleships(Rows/Columns, NShips, WaterBlocksL, SubmarinesL, MidPosL, LeftPosL, BottomPosL, RightPosL, TopPosL, HorizontalCounts, VerticalCounts) :-
    
    % gets the ship fleet depending on number of ships
    get_ship_fleet(NShips, ShipsShapes, X_Coords, Y_Coords, LexGroups),

    % 1 indexed!!!!
    domain(X_Coords, 1, Columns),
    domain(Y_Coords, 1, Rows),

    % initializes the list Ships
    createShipsList(0, X_Coords, Y_Coords, ShipsShapes, Ships, LastAssignedID),

    % water blocks
    createUnitaryObjects(LastAssignedID, WaterBlocksL, WaterBlocks, LastAssignedID2),
    % submarines hints
    createUnitaryObjects(LastAssignedID2, SubmarinesL, SubmarinesPos, LastAssignedID3),
    % ships' segments hints
    createUnitaryObjects(LastAssignedID3, MidPosL, MidPos, LastAssignedID4),
    createUnitaryObjects(LastAssignedID4, LeftPosL, LeftPos, LastAssignedID5),
    createUnitaryObjects(LastAssignedID5, BottomPosL, BottomPos, LastAssignedID6),
    createUnitaryObjects(LastAssignedID6, RightPosL, RightPos, LastAssignedID7),
    createUnitaryObjects(LastAssignedID7, TopPosL, TopPos, _),

    % join all objects in a single list for geost
    append([Ships, WaterBlocks, SubmarinesPos, MidPos, LeftPos, BottomPos, RightPos, TopPos], AllObjects),

    % collect IDs of objects to use in geost Rules
    getObjectsIDs(Ships, ShipsIDs),
    getObjectsIDs(WaterBlocks, WaterBlocksIDs),
    getObjectsIDs(SubmarinesPos, SubmarinesPosIDs),
    getObjectsIDs(MidPos, MidPosIDs),
    getObjectsIDs(LeftPos, LeftPosIDs),
    getObjectsIDs(BottomPos, BottomPosIDs),
    getObjectsIDs(RightPos, RightPosIDs),
    getObjectsIDs(TopPos, TopPosIDs),

    % horizontal and vertical shapes for each ship size. depending on NShips, may go to length 5.
    Shapes = [
        sbox(1, [0,0], [1, 1]),
        sbox(2, [0,0], [1, 2]),
        sbox(3, [0,0], [2, 1]),
        sbox(4, [0,0], [1, 3]),
        sbox(5, [0,0], [3, 1]),
        sbox(6, [0,0], [1, 4]),
        sbox(7, [0,0], [4, 1]),
        sbox(8, [0,0], [1, 5]),
        sbox(9, [0,0], [5, 1])
    ],

    BaseOptions = [
        /*
            lift constraint in geost that objects should be non-overlapping.
            that behaviour will be handled by the Rules.
        */
        overlap(true)
    ],

    % eliminate symmetries in answers
    addLexOptions(BaseOptions, LexGroups, Options),

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

        % checks if 2 objects intersect
        (intersect(Obj1, Obj2) --->
            #\ apart(Obj1, Obj2, 0)),

        % check if a ship is a submarine, that is, 1x1
        (isSubmarine(Ship) --->
            forall(Shape, sboxes([Ship^sid]),
                end(Ship, Shape, 1) #= origin(Ship, Shape, 1) + 1 #/\
                end(Ship, Shape, 2) #= origin(Ship, Shape, 2) + 1)),

        % check if a ship is horizontal, that is, height is 1 and width > 1
        (isHorizontal(Ship) --->
            forall(Shape, sboxes([Ship^sid]),
                end(Ship, Shape, 1) #> origin(Ship, Shape, 1) + 1 #/\
                end(Ship, Shape, 2) #= origin(Ship, Shape, 2) + 1)),

        % check if a ship is vertical, that is, width is 1 and height > 1
        (isVertical(Ship) --->
            forall(Shape, sboxes([Ship^sid]),
                end(Ship, Shape, 1) #= origin(Ship, Shape, 1) + 1 #/\
                end(Ship, Shape, 2) #> origin(Ship, Shape, 2) + 1)),

        % check if a ship starts at a given position
        (startsAt(Ship, Position) --->
            forall(Pos, sboxes([Position^sid]),
                forall(Shape, sboxes([Ship^sid]),
                    origin(Ship, Shape, 1) #= origin(Position, Pos, 1) #/\
                    origin(Ship, Shape, 2) #= origin(Position, Pos, 2)))),

        % check if a ship ends at a given position
        (endsAt(Ship, Position) --->
            forall(Pos, sboxes([Position^sid]),
                forall(Shape, sboxes([Ship^sid]),
                    end(Ship, Shape, 1) #= end(Position, Pos, 1) #/\
                    end(Ship, Shape, 2) #= end(Position, Pos, 2)))),        

        % guarantee the whole ship fits inside the board
        (forall(Ship, objects(ShipsIDs),
            forall(Shape, sboxes([Obj^sid]),
                end(Ship, Shape, 1) #=< Columns + 1 #/\ % +1 because 'end' calculates ship edge, not position
                end(Ship, Shape, 2) #=< Rows + 1))),

        % check ships are apart by at least 1 unit, in all directions
        (forall(Obj1, objects(ShipsIDs),
            forall(Obj2, objects(ShipsIDs),
                % if different objects, must be apart 1 unit
                (Obj2^oid #>= Obj1^oid) #\/ apart(Obj1, Obj2, 1)))),

        % verify there is not ship in water blocks
        (forall(Obj, objects(ShipsIDs),
            forall(WaterBlock, objects(WaterBlocksIDs),
                % must not intersect. apart by 0 units means touching each other but not intersecting
                apart(Obj, WaterBlock, 0)))),
        
        % for all required submarines positions, check they have a submarine
        (forall(Submarine, objects(SubmarinesPosIDs),
            exists(Ship, objects(ShipsIDs), 
                isSubmarine(Ship) #/\ intersect(Ship, Submarine)))),

        % verify that all mid positions are occupied
        (forall(ShipMidPos, objects(MidPosIDs),
            exists(Ship, objects(ShipsIDs),
                intersect(Ship, ShipMidPos) #/\
                #\ startsAt(Ship, ShipMidPos) #/\
                #\ endsAt(Ship, ShipMidPos)))),

        % verify that all left start positions are occupied
        (forall(LeftStartPos, objects(LeftPosIDs),
            exists(Ship, objects(ShipsIDs),
                isHorizontal(Ship) #/\ startsAt(Ship, LeftStartPos)))),

        % verify that all bottom start positions are occupied
        (forall(BottomStartPos, objects(BottomPosIDs),
            exists(Ship, objects(ShipsIDs),
                isVertical(Ship) #/\ startsAt(Ship, BottomStartPos)))),

        % verify that all right end positions are occupied
        (forall(RightEndPos, objects(RightPosIDs),
            exists(Ship, objects(ShipsIDs),
                isHorizontal(Ship) #/\ endsAt(Ship, RightEndPos)))),

        % verify that all top end positions are occupied
        (forall(TopEndPos, objects(TopPosIDs),
            exists(Ship, objects(ShipsIDs),
                isVertical(Ship) #/\ endsAt(Ship, TopEndPos))))

    ],
    geost(AllObjects, Shapes, Options, Rules),

    % apply restrictions of ships' segments count in rows and columns
    force_horizontal_ships_counts(1, HorizontalCounts, Ships),
    force_vertical_ships_counts(1, VerticalCounts, Ships),

    append([ShipsShapes, X_Coords, Y_Coords], AllVars),
    reset_timer, 
    labeling([ffc, median], AllVars),
    
    nl, write('Statistics:'), nl,
    fd_statistics,
    display_time,

    create_board(Rows/Columns, Ships, Shapes, WaterBlocksL, FinalBoard),
    display_board(FinalBoard, Rows/Columns, HorizontalCounts, VerticalCounts),
    (
        write('Get other solution? (Y/N) '),
        get_char(C),
        get_char(_), %Enter
        C \= 'Y',
        C \= 'y',
        !;
        reset_timer,
        fail
    ).

solve_battleships(_, _, _, _, _, _, _, _, _, _, _) :-
    write('No new solutions were found for the problem!'), nl, nl, !.

/**
 * Create Ships list
 * createShipsList(+LastID, +X_Coords, +Y_Coords, +Ships_Shapes, -Ships, -NewLastID)
 * Creates a list of ships from the given coords and shapes, returning the last assigned ID.
 *
 * LastID -> Last assigned ID.
 * X_Coords -> X coordinates of ships' position.
 * Y_Coords -> Y coordinates of ships' position.
 * Ships_Shapes -> Shapes of ships to create.
 * Ships -> List of ship objects
 * NewLastID -> Last ID assigned, after creating all the ships.
 */
createShipsList(LastID, [], [], [], [], LastID).
createShipsList(LastID, [Curr_X | Rest_X], [Curr_Y | Rest_Y], [Curr_Shape | Rest_Shapes], [object(CurrID, Curr_Shape, [Curr_X, Curr_Y]) | RestShips], NewLastID) :- 
    CurrID is LastID+1,
    createShipsList(CurrID, Rest_X, Rest_Y, Rest_Shapes, RestShips, NewLastID).

/**
 * Create Unitary objects
 * createUnitaryObjects(+LastID, +PositionsL, -Objects, -NewLastID)
 * Creates a list of objects of size 1x1 in the given positions.
 *
 * LastID -> Last ID that was assigned.
 * PositionsL -> New blocks positions.
 * Objects -> List containing the newly created blocks objects.
 * NewLastID -> New last ID assigned, after creating all the blocks.
 */
createUnitaryObjects(ID, [], [], ID).
createUnitaryObjects(LastID, [X/Y | PositionsL], [object(CurrID, 1, [X,Y]) | Objects], NewLastID) :-
    CurrID is LastID + 1,
    createUnitaryObjects(CurrID, PositionsL, Objects, NewLastID).

/**
 * Get objects IDs
 * getObjectsIDs(+Objects, -ObjectsIDs)
 * Collect the IDs of the objects in a list
 *
 * Objects -> List of objects to collect IDs.
 * ObjectsIDs -> List of IDs of the objects.
 */
getObjectsIDs([], []).
getObjectsIDs([object(ID, _, _) | Rest], [ID | RestIDs]) :-
    getObjectsIDs(Rest, RestIDs).

/**
 * Add Lex options
 * addLexOptions(+Options, +LexGroups, -NewOptions)
 * Adds an option 'lex([...])' for each list in LexGroups
 * to the Options List
 *
 * Options -> Base options.
 * LexGroups -> List of lex groups.
 * NewOptions -> Options after adding new options.
 */
addLexOptions(FinalOptions, [], FinalOptions).
addLexOptions(Options, [CurrGroup | RestGroups], NewOptions) :-
    append(Options, [lex(CurrGroup)], TempOptions),
    addLexOptions(TempOptions, RestGroups, NewOptions).

/**
 * Eliminate coordinates symmmetry
 * eliminate_coords_symmetry(+X1, +Y1, +X2, +Y2)
 * Applies a restriction between 2 points to eliminate symmetry in the labeling answers.
 * Was replaced by 'lex' in Options in geost, but could be used.
 *
 * X1 -> X coordinate of first point
 * Y1 -> Y coordinate of first point
 * X2 -> X coordinate of second point
 * Y2 -> Y coordinate of second point
 */
eliminate_coords_symmetry(X1, Y1, X2, Y2) :-
    % second point is farther from origin, or at same distance but with higher X
    (X1 + Y1 #< X2 + Y2) #\/ (X1 + Y1 #= X2 + Y2 #/\ X1 #=< X2).

/**
 * Apply shape size restrictions
 * apply_shape_size_restrictions(+ShapeID, Width, -Height)
 * Applies a restriction, given a shape size, on its width and height.
 *
 * ShapeID -> ID of shape
 * Width -> Width of given shape
 * Height -> Height of given shape
 */
apply_shape_size_restrictions(ShapeID, Width, Height) :-
    (ShapeID #= 1 #/\ Width #= 1 #/\ Height #= 1) #\/
    (ShapeID #= 2 #/\ Width #= 1 #/\ Height #= 2) #\/
    (ShapeID #= 3 #/\ Width #= 2 #/\ Height #= 1) #\/
    (ShapeID #= 4 #/\ Width #= 1 #/\ Height #= 3) #\/
    (ShapeID #= 5 #/\ Width #= 3 #/\ Height #= 1) #\/
    (ShapeID #= 6 #/\ Width #= 1 #/\ Height #= 4) #\/
    (ShapeID #= 7 #/\ Width #= 4 #/\ Height #= 1) #\/
    (ShapeID #= 8 #/\ Width #= 1 #/\ Height #= 5) #\/
    (ShapeID #= 9 #/\ Width #= 5 #/\ Height #= 1).

/**
 * Count ships in row
 * count_ships_in_row(+Row, +Ships, -Count)
 * Count number of ships in a row, having in account restrictions.
 *
 * Row -> Target Row.
 * Ships -> List with all the ships, to iterate over.
 * Count -> Resulting count.
 */
count_ships_in_row(_, [], 0).
count_ships_in_row(Row, [object(_, CurrShapeID, [_, Y]) | RestShips], Count) :-  
    apply_shape_size_restrictions(CurrShapeID, Width, Height),
    EndY #= Y + Height - 1,

    (Y #=< Row #/\ EndY #>= Row) #<=> Matched,
    Count #= NextCount + Matched * Width,
    count_ships_in_row(Row, RestShips, NextCount).

/**
 * Force horizontal ships counts.
 * force_horizontal_ships_counts(+Iter, +HorizontalCounts, +Ships)
 * Restrict number of ships' segments per row to the given values.
 *
 * Iter -> Current row.
 * HorizontalCounts -> List with count of segments per row.
 * Ships -> List with all the ships.
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

/**
 * Count ships count_ships_in_col row
 * count_ships_in_col(+Col, +Ships, -Count)
 * Count number of ships in a column, having in account restrictions.
 *
 * Col -> Target column.
 * Ships -> List with all the ships, to iterate over.
 * Count -> Resulting count.
 */
count_ships_in_col(_, [], 0).
count_ships_in_col(Col, [object(_, CurrShapeID, [X, _]) | RestShips], Count) :-   
    apply_shape_size_restrictions(CurrShapeID, Width, Height),
    EndX #= X + Width - 1,

    (X #=< Col #/\ EndX #>= Col) #<=> Matched,
    Count #= NextCount + Matched * Height,
    count_ships_in_col(Col, RestShips, NextCount).

/**
 * Force vertical ships counts.
 * force_vertical_ships_counts(+Iter, +VerticalCounts, +Ships)
 * Restrict number of ships' segments per column to the given values.
 *
 * Iter -> Current column.
 * VerticalCounts -> List with count of segments per column.
 * Ships -> List with all the ships.
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

/**
 * Create board
 * create_board(+Dimensions, +Ships, +Shapes, +WaterBlocks, -NewBoard)
 * Creates a board, a list of lists, with given ships and water blocks.
 *
 * Dimensions -> Size of the board, in the format Rows/Cols.
 * Ships -> List with the ships placed on the board, list of objects.
 * Shapes -> List with all the shapes of the ships.
 * WaterBlocks -> List with positions of the water blocks.
 * NewBoard -> Board that was created.
 */
create_board(Rows/Cols, Ships, Shapes, WaterBlocks, NewBoard) :-
    length(Board, Rows),
    assign_rows_length(Board, Cols),
    draw_ships(Board, Ships, Shapes),
    draw_blocks_in_board(Board, WaterBlocks, w),
    fill_missing(Board),
    reverse(Board, NewBoard).

/**
 * Assign rows length
 * assign_rows_length(+ListOfLists, +Size)
 * Sets the size of each list in a list of lists.
 *
 * ListOfLists -> List with lists which size should be changed.
 * Size -> Size of each list.
 */
assign_rows_length([], _) :- !.
assign_rows_length([Row | Rest], Cols) :-
    length(Row, Cols),
    assign_rows_length(Rest, Cols).

/**
 * Get shape
 * get_shape(+ShapeID, +Shapes, -Shape)
 * Finds the shape with given ID.
 *
 * ShapeID -> ID of shape to find.
 * Shapes -> List of shapes.
 * Shape -> Target shape.
 */
get_shape(ShapeID, [Shape | _], Shape) :-
    sbox(CurrShapeID, _, _) = Shape,
    ShapeID = CurrShapeID.

get_shape(ShapeID, [Shape | Rest], TargetShape) :-
    sbox(CurrShapeID, _, _) = Shape,
    ShapeID \= CurrShapeID,
    get_shape(ShapeID, Rest, TargetShape).

/**
 * Draw ships
 * draw_ships(+Board, +Ships, +Shapes)
 * Draws the given ships on the board, with an 's'.
 *
 * Board -> List of lists that represents the board.
 * Ships -> List of ships to draw.
 * Shapes -> List of shapes.
 */
draw_ships(_, [], _) :- !.
draw_ships(Board, [object(_, ShapeID, [X, Y]) | Rest], Shapes) :-
    get_shape(ShapeID, Shapes, Shape),
    sbox(_, _, [Sx, Sy]) = Shape,
    (
        Sx = 1, draw_ship_vertical(Board, X/Y, Sy, Sy);
        Sy = 1, draw_ship_horizontal(Board, X/Y, Sx, Sx)
    ), !,
    draw_ships(Board, Rest, Shapes).

/**
 * Draw ship vertical
 * draw_ship_vertical(+Board, +Position, +Height, +Iter)
 * Draws the ship at position Position on the board, vertically, with given height.
 *
 * Board -> List of lists that represents the board.
 * Position -> X/Y coordinates of ship.
 * Height -> Vertical size of ship.
 * Iter -> Iterator over the rows.
 */
draw_ship_vertical(_, _, _, 0) :- !.
draw_ship_vertical(Board, X/Y, Height, Iter) :-
    (
        Height = 1, Symbol = s; % submarine
        Iter = Height, Symbol = b; % bottom start position
        Iter = 1, Symbol = t; % top end position
        Symbol = m % middle position
    ), !,
    nth1(Y, Board, Row),
    nth1(X, Row, Symbol),
    NextY is Y+1,
    NextIter is Iter-1,
    draw_ship_vertical(Board, X/NextY, Height, NextIter).

/**
 * Draw ship horizontal
 * draw_ship_horizontal(+Board, +Position, +Width, +Iter)
 * Draws the ship at position Position on the board, horizontally, with given width.
 *
 * Board -> List of lists that represents the board.
 * Position -> X/Y coordinates of ship.
 * Width -> Horizontal size of ship.
 * Iter -> Iterator over the columns.
 */
draw_ship_horizontal(_, _, _, 0) :- !.
draw_ship_horizontal(Board, X/Y, Width, Iter) :-
    (
        Width = 1, Symbol = s; % submarine
        Iter = Width, Symbol = l; % bottom start position
        Iter = 1, Symbol = r; % top end position
        Symbol = m % middle position
    ), !,
    nth1(Y, Board, Row),
    nth1(X, Row, Symbol),
    NextX is X+1,
    NextIter is Iter-1,
    draw_ship_horizontal(Board, NextX/Y, Width, NextIter).

/**
 * Draw blocks in board
 * draw_blocks_in_board(+Board, +Positions, +Symbol)
 * Draws the given symbol in the given positions in the board.
 *
 * Board -> List of lists that represents the board.
 * Positions -> List of positions in format X/Y.
 * Symbol -> Symbol to draw.
 */
draw_blocks_in_board(_, [], _) :- !.
draw_blocks_in_board(Board, [X/Y | Rest], Symbol) :-
    nth1(Y, Board, Row),
    nth1(X, Row, Symbol),
    draw_blocks_in_board(Board, Rest, Symbol).


/**
 * Fill missing
 * fill_missing(+Board)
 * Assigns value 'e' to each remaining variable in the board.
 *
 * Board -> List of lists that represents the board.
 */
fill_missing([]) :- !.
fill_missing([Row | Rest]) :-
    fill_missing_row(Row),
    fill_missing(Rest).

/**
 * Fill missing row
 * fill_missing_row(+Row)
 * Assigns value 'e' to each remaining variable in the row.
 *
 * Row -> List that represents a row.
 */
fill_missing_row([]) :- !.
fill_missing_row([Ele | Rest]) :-
    (
        nonvar(Ele);
        Ele = e
    ), !,
    fill_missing_row(Rest).

    
test :-
    HorizontalCounts = [3, 2, 0, 4, 0, 3, 0, 3, 1, 4],
    VerticalCounts = [1, 4, 1, 0, 4, 4, 1, 3, 1, 1],
    WaterBlocks = [], % get water blocks from board
    Submarines = [],
    MidPos = [],
    LeftStartPos = [],
    RightEndPos = [],
    BottomStartPos = [],
    TopEndPos = [],
    solve_battleships(10/10, 10, WaterBlocks, Submarines, MidPos, LeftStartPos, BottomStartPos, RightEndPos, TopEndPos, HorizontalCounts, VerticalCounts).
