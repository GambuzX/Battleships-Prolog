read(File, Rows/Columns, Board, RowValues, ColumnValues) :-
    see(File),
    read_file(0, Rows/Columns, Board, RowValues, ColumnValues), !,
    seen, !.

read_file(0, Rows/Columns, Board, RowValues, ColumnValues):-
    read(Rows/Columns), !,
    read_file(1, _, Board, RowValues, ColumnValues). !.

read_file(1, _, Board, RowValues, ColumnValues):-
    read(Board), !,
    read_file(2, _, _, RowValues, ColumnValues), !.

read_file(2, _, _, RowValues, ColumnValues):-
    read(RowValues), !,
    read_file(3, _, _, _, ColumnValues), !.

read_file(3, _, _, _, ColumnValues):-
    read(ColumnValues), !.