function rba_linear_problem_numeric_display(rba_problem_numeric)

% rba_linear_problem_numeric_display(rba_problem_numeric)
%
% Display RBA optimality problem (numeric)
% 'rba_problem_numeric' is output of matlab function 'rba_problem_symbolic_to_numeric'

% display [A,a] as matrix
display('Matrix [A|a]')
[ {''}, rba_problem_numeric.x_id', {'RHS'}; rba_problem_numeric.a_eq_id, num2cell(rba_problem_numeric.A_eq), num2cell(rba_problem_numeric.a_eq)]

% display [B,b] as matrix

display('Matrix [B|b]')
[ {''}, rba_problem_numeric.x_id', {'RHS'}; rba_problem_numeric.b_in_id, num2cell(rba_problem_numeric.B_in), num2cell(rba_problem_numeric.b_in)]
