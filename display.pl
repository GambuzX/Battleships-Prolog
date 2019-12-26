/*********************\
|* Display Functions *|
\*********************/

/**
 * Display Menu Options
 * display_menu_options
 * Shows the menu options
 */
display_menu_options:-
    nl,           
    write(' MAIN MENU '), nl, nl,
    write(' 1- Solve first board.'), nl,
    write(' 2- Solve second board.'), nl,
    write(' 3- Solve third board.'), nl,
    write(' 4- Solve fourth board.'), nl,
    write(' 5- Solve fifth board.'), nl,
    write(' 6- Solve other board.'), nl,
    write(' 7- Generate board.'), nl, nl.

/**
 * Display a error message
 * error_msg(+Msg)
 * Displays a error message on screen and fails.
 *
 * Msg -> Message to be displayed.
 */
error_msg(Msg) :-
    nl, write(Msg), nl, nl, fail.