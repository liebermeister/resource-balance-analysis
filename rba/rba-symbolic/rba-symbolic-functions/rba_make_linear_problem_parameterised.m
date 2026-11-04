function [rba_problem, rba_problem_numerical_1, rba_model_indices] = rba_make_linear_problem_parameterised(rba_model_schema, rba_model_components, parameter_name)

% [rba_problem, rba_problem_numerical_1] = rba_make_linear_problem_parameterised(rba_model_schema, rba_model_components, parameter_name)
%
% Build a parameter-dependent RBA problem (in 'rba_problem' format (2), see 'help rba_problem')
%   MatrixEq   = MatrixEq_1   + p * MatrixEq_p
%   MatrixIneq = MatrixIneq_1 + p * MatrixIneq_p
% where p is a scalar parameter (default: 'growth_rate'). This is the format needed for
% growth rate maximisation with 'rba' (options.method = 'maximise_growth' or 'screen_growth').
%
% The matrices are obtained by building the numerical problem for p = 0, 1, and 2 (all other
% parameters as given in 'rba_model_components'); the function checks that the problem is
% linear in p. For this to work, the matrices depending on p must not be given explicitly
% in rba_model_components.Connection, but must be declared in the schema as 'is_diagonal_matrix_of'
% the parameter (e.g. growth_rate_Iprt = growth_rate * I).
%
% Outputs
%   rba_problem              parameterised problem ('rba_problem' format (2))
%   rba_problem_numerical_1  numerical problem ('linear-problem-numerical') for p = 1

eval(default('parameter_name','''growth_rate'''));

values = [0, 1, 2];
for it = 1:length(values)
  my_components = rba_model_components;
  my_components.Parameter.(parameter_name).Value = values(it);
  warning_state = warning('off','rba_make_model_indices:unused_connections');
  rba_model_indices    = rba_make_model_indices(rba_model_schema, my_components);
  warning(warning_state);
  rba_problem_symbolic = rba_make_linear_problem_symbolic(rba_model_indices);
  LP{it}               = rba_make_linear_problem_numerical(rba_problem_symbolic, rba_model_indices);
end

A_1 = LP{1}.A;  A_p = LP{2}.A - LP{1}.A;
B_1 = LP{1}.B;  B_p = LP{2}.B - LP{1}.B;

tol = 10^-10;
if max(abs(nonzeros(LP{3}.A - (A_1 + 2 * A_p)))) > tol | max(abs(nonzeros(LP{3}.B - (B_1 + 2 * B_p)))) > tol
  error(sprintf('The constraint matrices are not linear in parameter %s', parameter_name));
end
if ~isequal(LP{1}.a, LP{2}.a, LP{3}.a) || ~isequal(LP{1}.b, LP{2}.b, LP{3}.b) || ...
   ~isequal(LP{1}.x_lb, LP{2}.x_lb, LP{3}.x_lb) || ~isequal(LP{1}.x_ub, LP{2}.x_ub, LP{3}.x_ub)
  error(sprintf('Bounds or right-hand sides depend on parameter %s; this is not supported', parameter_name));
end
if nnz(A_p) + nnz(B_p) == 0
  warning('The constraints do not depend on parameter %s (are the matrices given explicitly in model components?)', parameter_name);
end

rba_problem = struct;
rba_problem.Variables.Names          = LP{1}.id_x;
rba_problem.Variables.LowerBounds    = LP{1}.x_lb;
rba_problem.Variables.UpperBounds    = LP{1}.x_ub;
rba_problem.Constraints.NamesEq      = LP{1}.id_a;
rba_problem.Constraints.NamesIneq    = LP{1}.id_b;
rba_problem.Constraints.VectorEq     = LP{1}.a;
rba_problem.Constraints.VectorIneq   = LP{1}.b;
rba_problem.Constraints.MatrixEq_1   = A_1;
rba_problem.Constraints.MatrixEq_p   = A_p;
rba_problem.Constraints.MatrixIneq_1 = B_1;
rba_problem.Constraints.MatrixIneq_p = B_p;
rba_problem.Parameter                = parameter_name;

rba_problem_numerical_1 = LP{2};
