function rba_problem = lp_problem_compact_to_rba_problem(lp_problem);

rba_problem.Variables.Names       = lp_problem.col_names;
rba_problem.Variables.LowerBounds = lp_problem.LB;
rba_problem.Variables.UpperBounds = lp_problem.UB;
ind_eq      = find(strcmp('E',lp_problem.row_signs));
ind_lower   = find(strcmp('L',lp_problem.row_signs));
% ASK OLIVER IF HE USES U OR G?
ind_greater = find(strcmp('U',lp_problem.row_signs)); 
ind_ineq    = [ind_lower; ind_greater];
%sgn_ineq    = [ones(size(ind_lower)); - ones(size(ind_greater))]; 
rba_problem.Constraints.NamesEq = lp_problem.row_names(ind_eq,:);
rba_problem.Constraints.NamesIneq = lp_problem.row_names(ind_ineq,:);
rba_problem.Constraints.MatrixEq = lp_problem.A(ind_eq,:);
rba_problem.Constraints.VectorEq = lp_problem.b(ind_eq,:);
rba_problem.Constraints.VectorIneq = [lp_problem.b(ind_lower,:); -lp_problem.b(ind_greater,:)];
rba_problem.Constraints.MatrixIneq = [lp_problem.A(ind_lower,:); -lp_problem.A(ind_greater,:)];
