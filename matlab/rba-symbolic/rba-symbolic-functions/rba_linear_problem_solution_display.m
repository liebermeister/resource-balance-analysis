function rba_linear_problem_solution_display(rba_problem_numeric, x_opt, f_opt, w_opt)

% rba_linear_problem_solution_display(rba_problem_numeric, x_opt, f_opt, w_opt)
%
% Display results of RBA linear optimality problem
% (output of matlab function "rba_linear_problem_solve")
  
display('State variables');
pm(x_opt,rba_problem_numeric.id_x)

if nargin>3,
  display('Shadow prices (equality constraints)');
  pm(w_opt.eqlin,rba_problem_numeric.id_a)
  display('Shadow prices (inequality constraints)');
  pm(w_opt.ineqlin,rba_problem_numeric.id_b)
  display('Shadow prices (lower bounds)');
  pm(w_opt.lower,rba_problem_numeric.id_x)
  display('Shadow prices (upper bounds)');
  pm(w_opt.upper,rba_problem_numeric.id_x)
end
