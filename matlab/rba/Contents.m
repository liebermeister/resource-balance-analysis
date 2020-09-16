% Matlab data structures for RBA models (parameterised LP problem)
% ----------------------------------------------------------------
%
% == Format 'rba_problem' in two forms, for (1) fixed matrices, (2) parameterised matrices
%
% for details of the data structure, type "help rba_problem"
%
%
% == Alternative format 'lp_problem_numerical' (very similar format, see rba-symbolic)
%
%  lp_problem_numerical.id_x
%  lp_problem_numerical.x_lb
%  lp_problem_numerical.x_ub
%  lp_problem_numerical.id_a
%  lp_problem_numerical.id_b
%  lp_problem_numerical.A   
%  lp_problem_numerical.a   
%  lp_problem_numerical.B   
%  lp_problem_numerical.b   
%
% Conversion functions:
%  lp_problem_numerical_to_rba_problem.m
%  rba_problem_to_lp_problem_numerical.m
%
%
% == Alternative format 'lp_problem_compact' (for simple LP problems, see rba-symbolic, )
%
%  lp_problem_compact.col_names: {ns x 1 cell}
%  lp_problem_compact.row_names: {nc x 1 cell}
%  lp_problem_compact.LB:        [ns x 1 double]
%  lp_problem_compact.UB:        [ns x 1 double]
%  lp_problem_compact.A:         [nc x ns double]
%  lp_problem_compact.b:         [nc x 1 double]
%  lp_problem_compact.row_signs: {nc x 1 cell}
%
% Conversion function:
%   rba_problem_numerical_to_lp_problem_compact
%
% RBA Functions
% -------------
%
% RBA solver function "rba.m"
