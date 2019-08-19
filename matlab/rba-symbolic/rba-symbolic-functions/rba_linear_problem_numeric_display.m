function rba_linear_problem_numeric_display(rba_problem_numeric)

% rba_linear_problem_numeric_display(rba_problem_numeric)
%
% Display RBA optimality problem (numeric)
% 'rba_problem_numeric' is output of matlab function 'rba_problem_symbolic_to_numeric'

% display [A,a] as matrix
display('Matrix [A|a]')
[ {''}, rba_problem_numeric.id_x', {'RHS'}; rba_problem_numeric.id_a, num2cell(rba_problem_numeric.A), num2cell(rba_problem_numeric.a)]

% display [B,b] as matrix

display('Matrix [B|b]')
[ {''}, rba_problem_numeric.id_x', {'RHS'}; rba_problem_numeric.id_b, num2cell(rba_problem_numeric.B), num2cell(rba_problem_numeric.b)]
