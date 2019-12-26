/*******************\
|* Input Functions *|
\*******************/

/**
 * Read Menu Option
 * read_menu_option(-Option)
 * Reads an integer between 1 and 3
 *
 * Option -> Selected menu option
 */
read_menu_option(Option) :-
    read_option(3, Option).

/**
 * Get Single Integer
 * get_single_integer(-Int)
 * Read a single integer value from the user
 *
 * Int -> Variable to return read integer
 */
get_single_integer(Int) :-
    get_code(Ch),
    Ch >= 48,
    Ch =< 57,
    name(Int, [Ch]).

/**
 * Read Board Option
 * read_board_option(-Option)
 * Reads an integer between 1 and 7
 *
 * Option -> Selected board option
 */
read_board_option(Option) :-
    read_option(7, Option).

/**
 * Read Option
 * read_option(+Max, -Option)
 * Reads an integer between 1 and Max
 *
 * Option -> Selected option
 */
read_option(Max, Option) :-
    get_single_integer(Option),
    get_code(_), %Get \n character
    Option >= 1,
    Option =< Max.