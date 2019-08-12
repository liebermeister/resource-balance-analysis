function [x_opt, f_opt, w_opt] = rba_linear_problem_solve(rba_problem_numeric,id_opt)

% [x_opt, f_opt, w_opt] = rba_linear_problem_solve(rba_problem_numeric,id_opt)
%
% Solve RBA linear optimality problem, maximising the state variable with identifier id_opt
%
% rba_problem_numeric: output of matlab function 'rba_problem_numeric'

epsilon = 10^-8;
  
LP      = rba_problem_numeric;

ind_opt = label_names(id_opt, LP.x_id);
c       = zeros(size(LP.x_lb));
c(ind_opt) = -1;

warning('off','optim:linprog:WillRunDiffAlg')
opt = optimset('Display','off');

[x_opt, f_opt, exitflag, output, w_opt] = linprog(c, LP.B_in, LP.b_in, LP.A_eq, LP.a_eq, LP.x_lb, LP.x_ub,[],opt);

x_opt         = round_zero(x_opt,epsilon);
w_opt.eqlin   = round_zero(w_opt.eqlin,epsilon);
w_opt.ineqlin = round_zero(w_opt.ineqlin,epsilon);
w_opt.lower   = round_zero(w_opt.lower,epsilon);
w_opt.upper   = round_zero(w_opt.upper,epsilon);

function x = round_zero(x,epsilon)
  
x(abs(x)<epsilon) = 0;
