function [x_opt, f_opt, w_opt, exitflag] = rba_linear_problem_solve(rba_problem_numerical, id_opt)

% [x_opt, f_opt, w_opt, exitflag] = rba_linear_problem_solve(rba_problem_numerical, id_opt)
%
% Solve RBA linear optimality problem, maximising the state variable with identifier id_opt
% (alternatively, id_opt can be a numerical weight vector c; then c' * x is maximised)
%
% rba_problem_numerical: output of matlab function 'rba_make_linear_problem_numerical'
%
% Outputs
%   x_opt    optimal state vector (entries with absolute values < 10^-8 are set to 0)
%   f_opt    optimal objective value (value of the maximised variable)
%   w_opt    Lagrange multipliers (shadow prices) as returned by linprog
%   exitflag exitflag from linprog (1: optimum found); if the problem is not solved,
%            a warning is issued and x_opt, f_opt are set to NaN

epsilon = 10^-8;

LP = rba_problem_numerical;

if ischar(id_opt)
  ind_opt = label_names({id_opt}, LP.id_x);
  if ind_opt == 0
    error(sprintf('Variable %s to be maximised not found', id_opt));
  end
  c = zeros(size(LP.x_lb));
  c(ind_opt) = -1;
else
  c = -id_opt(:);
end

[x_opt, f_opt, exitflag, ~, w_opt] = rba_linprog(c, LP.B, LP.b, LP.A, LP.a, LP.x_lb, LP.x_ub);

if exitflag ~= 1
  warning('rba_linear_problem_solve:not_solved', 'Linear problem not solved (linprog exitflag %d)', exitflag);
  x_opt = nan * ones(size(LP.x_lb));
  f_opt = nan;
  return
end

f_opt         = -f_opt;
x_opt         = round_zero(x_opt,epsilon);
w_opt.eqlin   = round_zero(w_opt.eqlin,epsilon);
w_opt.ineqlin = round_zero(w_opt.ineqlin,epsilon);
w_opt.lower   = round_zero(w_opt.lower,epsilon);
w_opt.upper   = round_zero(w_opt.upper,epsilon);


function x = round_zero(x,epsilon)

x(abs(x)<epsilon) = 0;
