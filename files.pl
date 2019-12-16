/**
 * Read
 * read(+File, -Rows/Columns, -Board, -RowValues, -ColumnValues)
 * Reads the file
 *
 * File -> Path of the file.
 * Rows -> Number of rows of the board.
 * Columns -> Number of columns of the board.
 * Board -> The battleships board (list of lists).
 * RowValues -> List of numbers with the number of cells occupied in each row.
 * ColumnValues -> List of numbers with the number of cells occupied in each column.
 */
read(File, Rows/Columns, Board, RowValues, ColumnValues) :-
    see(File),
    read(Rows/Columns), !,
    read(Board), !,
    read(RowValues), !,
    read(ColumnValues), !,
    seen, !.

/**
 * Write
 * write(+File, -Rows/Columns, -Board, -RowValues, -ColumnValues)
 * Writes to the file
 *
 * File -> Path of the file.
 * Rows -> Number of rows of the board.
 * Columns -> Number of columns of the board.
 * Board -> The battleships board (list of lists).
 * RowValues -> List of numbers with the number of cells occupied in each row.
 * ColumnValues -> List of numbers with the number of cells occupied in each column.
 */
write(File, Rows/Columns, Board, RowValues, ColumnValues) :-
    tell(File),
    write(Rows/Columns), write('.'), nl,
    write(Board), write('.'), nl,
    write(RowValues), write('.'), nl,
    write(ColumnValues), write('.'), nl,
    told, !.