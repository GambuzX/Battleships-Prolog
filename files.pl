/**
 * Read
 * read(+File, -NShips, -Rows/Columns, -Board, -RowValues, -ColumnValues)
 * Reads the file
 *
 * File -> Path of the file.
 * NShips -> Number of ships hidden in the board.
 * Rows -> Number of rows of the board.
 * Columns -> Number of columns of the board.
 * Board -> The battleships board (list of lists).
 * RowValues -> List of numbers with the number of cells occupied in each row.
 * ColumnValues -> List of numbers with the number of cells occupied in each column.
 */
read(File, NShips, Rows/Columns, Board, RowValues, ColumnValues) :-
    see(File),
    read(NShips), !,
    read(Rows/Columns), !,
    read(Board), !,
    read(RowValues), !,
    read(ColumnValues), !,
    seen, !.

/**
 * Read List
 * read_list(+File, -List)
 * Reads a list from a file
 * 
 * File -> Path of the file
 * List -> List read from the file
 */
 read_list(File, List) :-
    see(File),
    read(List),
    seen, !.

/**
 * Write
 * write(+File, +NShips, +Rows/Columns, +Board, +RowValues, +ColumnValues)
 * Writes to the file
 *
 * File -> Path of the file.
 * NShips -> Number of ships.
 * Rows -> Number of rows of the board.
 * Columns -> Number of columns of the board.
 * Board -> The battleships board (list of lists).
 * RowValues -> List of numbers with the number of cells occupied in each row.
 * ColumnValues -> List of numbers with the number of cells occupied in each column.
 */
write(File, NShips, Rows/Columns, Board, RowValues, ColumnValues) :-
    tell(File),
    write(NShips), write('.'), nl,
    write(Rows/Columns), write('.'), nl,
    write(Board), write('.'), nl,
    write(RowValues), write('.'), nl,
    write(ColumnValues), write('.'), nl,
    told, !.

save_time(FileName, VarLabel, ValLabel, OrdLabel, Time) :-
    open('output.txt', append, File),
    write(File, FileName), write(File, ' - '), 
    write(File, VarLabel), write(File, ' - '),
    write(File, VarLabel), write(File, ' - '),
    write(File, OrdLabel), write(File, ' - '),
    write(File, Time), write(File, '\n'),
    close(File), !.