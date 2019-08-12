function rba_linear_problem_numeric_display(LP_numeric)

% display [A,a] as matrix
display('Matrix [A|a]')
[ {''}, LP_numeric.x_id', {'RHS'}; LP_numeric.a_eq_id, num2cell(LP_numeric.A_eq), num2cell(LP_numeric.a_eq)]

% display [B,b] as matrix

display('Matrix [B|b]')
[ {''}, LP_numeric.x_id', {'RHS'}; LP_numeric.b_in_id, num2cell(LP_numeric.B_in), num2cell(LP_numeric.b_in)]
