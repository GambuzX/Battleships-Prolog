/*******************\
|* Input Functions *|
\*******************/

/**
 * Read Menu Option
 * read_menu_option(-Option)
 * Reads an integer between 1 and 7
 *
 * Option -> Selected menu option
 */
read_menu_option(Option) :-
    get_single_integer(Option),
    get_code(_), %Get \n character
    Option >= 1,
    Option =< 7.

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