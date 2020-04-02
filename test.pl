:- include('battleships.pl').

test_solve_battleships(FileList, VarLabelFile, ValLabelFile, OrdLabelFile) :-
    read_list(VarLabelFile, VarList), !,
    read_list(ValLabelFile, ValList), !,
    read_list(OrdLabelFile, OrdList), !,
    test_solve_battleships_files(FileList, VarList, ValList, OrdList), !.

test_solve_battleships_files([], _, _, _) :- !.

test_solve_battleships_files([File|FileList], VarList, ValList, OrdList) :- 
    get_file_path(File, FileName),
    test_solver(FileName, 3, VarList, ValList, OrdList),
    test_solve_battleships(FileList).


test_solver(_, 0, _, _, _) :- !.

test_solver(FileName, N, VarList, ValList, OrdList) :-
    get_battleships_board(FileName, NShips, Row/Column, Board, RowVal, ColVal),
    get_other_solver_values(Board, WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks),
    run_tests(FileName, Row/Column, NShips, RowVal, ColVal, 
              WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks,
              VarList, ValList, OrdList),
    
    N1 is N - 1,
    test_solver(FileName, N1, VarList, ValList, OrdList).


get_other_solver_values(Board, WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks) :-
    length(Board, NumRows),
    get_blocks(Board, w, NumRows, WaterBlocks),
    get_blocks(Board, s, NumRows, SubmarineBlocks),
    get_blocks(Board, m, NumRows, MiddleBlocks),
    get_blocks(Board, l, NumRows, LeftBlocks),
    get_blocks(Board, b, NumRows, BottomBlocks),
    get_blocks(Board, r, NumRows, RightBlocks),
    get_blocks(Board, t, NumRows, TopBlocks).

run_tests(_, _, _, _, _, _, _, _, _, _, _, _, [], _, _) :- !.

run_tests(FileName, Rows/Columns, NShips, HorizontalCounts, VerticalCounts, 
          WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, 
          [VarLabel | VarLabelL], ValLabelL, OrdLabelL) :-
    run_variable_tests(FileName, Rows/Columns, NShips, HorizontalCounts, VerticalCounts, 
          WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, 
          VarLabel, ValLabelL, OrdLabelL),
    run_tests(FileName, Rows/Columns, NShips, HorizontalCounts, VerticalCounts, 
          WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, 
          VarLabelL, ValLabelL, OrdLabelL).

run_variable_tests(_, _, _, _, _, _, _, _, _, _, _, _, _, [], _) :- !.

run_variable_tests(FileName, Rows/Columns, NShips, HorizontalCounts, VerticalCounts, 
          WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, 
          VarLabel, [ValLabel | ValLabelL], OrdLabelL) :-
    run_value_tests(FileName, Rows/Columns, NShips, HorizontalCounts, VerticalCounts, 
          WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, 
          VarLabel, ValLabel, OrdLabelL),
    run_variable_tests(FileName, Rows/Columns, NShips, HorizontalCounts, VerticalCounts, 
          WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, 
          VarLabel, ValLabelL, OrdLabelL).

run_value_tests(_, _, _, _, _, _, _, _, _, _, _, _, _, _, []) :- !.

run_value_tests(FileName, Rows/Columns, NShips, HorizontalCounts, VerticalCounts, 
          WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, 
          VarLabel, ValLabel, [OrdLabel | OrdLabelL]) :-
    solve_battleships(Rows/Columns, NShips, WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, 
                      HorizontalCounts, VerticalCounts, VarLabel, ValLabel, OrdLabel, Time),
    save_time(FileName, VarLabel, ValLabel, OrdLabel, Time),
    run_value_tests(FileName, Rows/Columns, NShips, HorizontalCounts, VerticalCounts, 
          WaterBlocks, SubmarineBlocks, MiddleBlocks, LeftBlocks, BottomBlocks, RightBlocks, TopBlocks, 
          VarLabel, ValLabel, OrdLabelL).    
