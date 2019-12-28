/*********************\
|* Display Functions *|
\*********************/

/**
 * Display Game Name
 * display_game_name
 */
display_game_name :-
    write('/=======================================================================\\'), nl,
    write('|  ___    ____  _____ _____        ____  ____        _____  ___   ____  |'), nl,
    write('| |   \\  |    |   |     |   |     |     |     |    |   |   |   | |      |'), nl,
    write('| |___/  |____|   |     |   |     |__   |___  |____|   |   |___| |___   |'), nl,
    write('| |   \\  |    |   |     |   |     |         | |    |   |   |         |  |'), nl,
    write('| |___/  |    |   |     |   |____ |____ ____| |    | __|__ |     ____|  |'), nl,
    write('\\=======================================================================/'), nl.


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