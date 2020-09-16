function rba_linear_problem_numerical_display(rba_problem_numerical)

% rba_linear_problem_numerical_display(rba_problem_numerical)
%
% Display RBA optimality problem (numerical)
% 'rba_problem_numerical' is output of matlab function 'rba_problem_symbolic_to_numerical'

% display [A,a] as matrix
display('Matrix [A|a]')
[ {''}, rba_problem_numerical.id_x', {'RHS'}; rba_problem_numerical.id_a, num2cell(rba_problem_numerical.A), num2cell(rba_problem_numerical.a)]

% display [B,b] as matrix

display('Matrix [B|b]')
[ {''}, rba_problem_numerical.id_x', {'RHS'}; rba_problem_numerical.id_b, num2cell(rba_problem_numerical.B), num2cell(rba_problem_numerical.b)]
