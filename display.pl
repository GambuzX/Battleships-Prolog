/*********************\
|* Display Functions *|
\*********************/

/**
 * Display Game Name
 * display_game_name
 */
display_game_name :-
    display_ship,
    write('/=======================================================================\\'), nl,
    write('|  ___    ____  _____ _____        ____  ____        _____  ___   ____  |'), nl,
    write('| |   \\  |    |   |     |   |     |     |     |    |   |   |   | |      |'), nl,
    write('| |___/  |____|   |     |   |     |__   |___  |____|   |   |___| |___   |'), nl,
    write('| |   \\  |    |   |     |   |     |         | |    |   |   |         |  |'), nl,
    write('| |___/  |    |   |     |   |____ |____ ____| |    | __|__ |     ____|  |'), nl,
    write('\\=======================================================================/'), nl.

display_ship :-
    write('                                     |__'), nl,
    write('                                     |\\/'), nl,
    write('                                     ---'), nl,
    write('                                     / | ['), nl,
    write('                              !      | |||'), nl,
    write('                            _/|     _/|-++\''), nl,
    write('                        +  +--|    |--|--|_ |-'), nl,
    write('                     { /|__|  |/\\__|  |--- |||__/'), nl,
    write('                    +---------------___[}-_===_.\'____               /\\'), nl,
    write('                ____`-\' ||___-{]_| _[}-  |     |_[___\\==--          \\/  _'), nl,
    write(' __..._____--==/___]_|__|_____________________________[___\\==--___,----\' 7'), nl,
    write('|                                                                       /'), nl,
    write(' \\______________________________________________________________________|'), nl.

/**
 * Display Board
 * display_board(+Board, +Rows/Columns, +HorizontalCounts, +VerticalCounts)
 * Displays the puzzle board
 *
 * Board -> The puzzle board
 * Rows/Columns -> A pair with the number of rows and the number of columns
 * HorizontalCounts -> The number of ship pieces in each row
 * VerticalCounts -> The number of ship pieces in each column
 */
display_board(Board, Rows/Columns, HorCount, VertCount) :-
    reverse(HorCount, RevHorCount),
    display_rows(Board, Rows/Columns, RevHorCount, 1),  
    display_column_values(VertCount, 1), !.

/**
 * Display Rows
 * display_rows(+Board, +Rows/Columns, +HorizontalCounts, +RowNumber)
 * Displays the puzzle board
 *
 * Board -> The puzzle board
 * Rows/Columns -> A pair with the number of rows and the number of columns
 * HorizontalCounts -> The number of ship pieces in each row
 * RowNumber -> The number of the current row
 */
display_rows([Row|Rest], Rows/Columns, [RowCount|HorCount], 1) :-
    display_first_row(Columns, 1), 
    display_row(Row, Columns, RowCount, 1),
    display_line_separator(Columns, 1),
    display_rows(Rest, Rows/Columns, HorCount, 2).

display_rows([Row|[]], Rows/Columns, [RowCount|[]], Rows) :-
    display_row(Row, Columns, RowCount, 1),
    display_last_row(Columns, 1).

display_rows([Row|Rest], Rows/Columns, [RowCount|HorCount], RowNum) :-
    display_row(Row, Columns, RowCount, 1),
    display_line_separator(Columns, 1),
    NextRow is RowNum + 1,
    display_rows(Rest, Rows/Columns, HorCount, NextRow).

/**
 * Display First Row
 * display_first_row(+Columns, +ColumnNumber)
 * Displays the first row
 *
 * Columns -> The number of columns
 * ColumnNumber -> The number of the current column
 */
display_first_row(Columns, 1) :-
    %write('╔'),
    put_code(201),
    %write('═'),
    put_code(205),
    put_code(205),
    put_code(205),
    %write('╦'),
    put_code(203),
    display_first_row(Columns, 2).

display_first_row(Columns, Columns) :-
    %write('═'),
    put_code(205),
    put_code(205),
    put_code(205),
    %write('╗'), 
    put_code(187),
    nl.

display_first_row(Columns, ColNum) :-
    %write('═'),
    put_code(205),
    put_code(205),
    put_code(205),
    %write('╦'),
    put_code(203),
    NextCol is ColNum + 1,
    display_first_row(Columns, NextCol).

/**
 * Display Last Row
 * display_last_row(+Columns, +ColumnNumber)
 * Displays the last row
 *
 * Columns -> The number of columns
 * ColumnNumber -> The number of the current column
 */
display_last_row(Columns, 1) :-
    %write('╚'),
    put_code(200),
    %write('═'),
    put_code(205),
    put_code(205),
    put_code(205),
    %write('╩'),
    put_code(202),
    display_last_row(Columns, 2).

display_last_row(Columns, Columns) :-
    %write('═'),
    put_code(205),
    put_code(205),
    put_code(205),
    %write('╝'),
    put_code(188), 
    nl.

display_last_row(Columns, ColNum) :-
    %write('═'),
    put_code(205),
    put_code(205),
    put_code(205),
    %write('╩'),
    put_code(202),
    NextCol is ColNum + 1,
    display_last_row(Columns, NextCol).

/**
 * Display Line Separator
 * display_line_separator(+Columns, +ColumnNumber)
 * Displays the line separator
 *
 * Columns -> The number of columns
 * ColumnNumber -> The number of the current column
 */
display_line_separator(Columns, 1) :-
    %write('╠'),
    put_code(204),
    %write('═'),
    put_code(205),
    put_code(205),
    put_code(205),
    %write('╬'),
    put_code(206),
    display_line_separator(Columns, 2).

display_line_separator(Columns, Columns) :-
    %write('═'),
    put_code(205),
    put_code(205),
    put_code(205),
    %write('╣'), 
    put_code(185),
    nl.

display_line_separator(Columns, ColNum) :-
    %write('═'),
    put_code(205),
    put_code(205),
    put_code(205),
    %write('╬'),
    put_code(206),
    NextCol is ColNum + 1,
    display_line_separator(Columns, NextCol).

/**
 * Display Row
 * display_row(+Row, +Columns, +RowCount, +ColumnNumber)
 * Displays a board row
 *
 * Row -> The board row
 * Columns -> The number of columns
 * RowCount -> The number of ship pieces in the row
 * ColumnNumber -> The number of the current column
 */
display_row([Char|[]], Columns, RowCount, Columns) :-
    %write('║'),
    put_code(186),
    display_character(Char),
    %write('║'),
    put_code(186),
    write(' '),
    write(RowCount), nl.

display_row([Char|OtherChars], Columns, RowCount, ColNum) :-
    %write('║'),
    put_code(186),
    display_character(Char),
    NextCol is ColNum + 1,
    display_row(OtherChars, Columns, RowCount, NextCol).

/**
 * Display Character
 * display_character(+Char)
 * Displays a board character
 *
 * Char -> The character to display
 */
display_character(e) :-
    write('   ').

display_character(s) :-
    write(' '),
    %write('█').
    put_code(219),
    write(' ').

display_character(w) :-
    write(' '),
    %write('░').
    put_code(176),
    write(' ').

/**
 * Display Column Values
 * display_column_values(+VerticalCounts, +ColumnNumber)
 * 
 * VerticalCounts -> The number of ship pieces in each column
 * ColumnNumber -> Number of the current column
 */
display_column_values([], _) :- nl, nl.

display_column_values([Count|VerticalCounts], 1) :-
    write('  '),
    write(Count),
    display_column_values(VerticalCounts, 2).

display_column_values([Count|VerticalCounts], 2) :-
    write('   '),
    write(Count),
    display_column_values(VerticalCounts, 2).

/**
 * Display Menu Options
 * display_menu_options
 * Shows the menu options
 */
display_menu_options:-
    nl,           
    write(' MAIN MENU '), nl, nl,
    write(' 1- Solve board.'), nl,
    write(' 2- Generate board.'), nl,
    write(' 3- Exit.'), nl, nl.

/**
 * Display a error message
 * error_msg(+Msg)
 * Displays a error message on screen and fails.
 *
 * Msg -> Message to be displayed.
 */
error_msg(Msg) :-
    nl, write(Msg), nl, nl, fail.


/**
 * Display Choose Board
 * display_choose_board
 * Shows the options to solve
 */
display_choose_board :-
    nl,
    write(' 1- Solve First Board.'), nl,
    write(' 2- Solve Second Board.'), nl,
    write(' 3- Solve Third Board.'), nl,
    write(' 4- Solve Fourth Board.'), nl,
    write(' 5- Solve Fifth Board.'), nl,
    write(' 6- Solve Other Board.'), nl,
    write(' 7- Back to Menu'), nl, nl.

/**
 * Display Generate Board
 * display_generate_board
 */
display_generate_board :-
    write('GENERATE BOARD'), nl, nl,
    write('Insert the name of the output file (please end the name with a \'.\'): ').

/**
 * Display Choose Input Board
 * display_choose_input_board
 */
 display_choose_input_board :-
    write('Insert the name of the input file (please end the name with a \'.\'): ').