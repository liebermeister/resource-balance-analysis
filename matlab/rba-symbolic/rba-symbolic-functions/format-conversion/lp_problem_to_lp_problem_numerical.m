function lp_problem_numerical = lp_problem_to_lp_problem_numerical(lp_problem);

lp_problem_numerical.id_x = lp_problem.Variables.Names        ;
lp_problem_numerical.x_lb = lp_problem.Variables.LowerBounds  ;
lp_problem_numerical.x_ub = lp_problem.Variables.UpperBounds  ;
lp_problem_numerical.id_a = lp_problem.Constraints.NamesEq    ;
lp_problem_numerical.id_b = lp_problem.Constraints.NamesIneq  ;
lp_problem_numerical.A    = lp_problem.Constraints.MatrixEq   ;
lp_problem_numerical.a    = lp_problem.Constraints.VectorEq   ;
lp_problem_numerical.B    = lp_problem.Constraints.VectorIneq ;
lp_problem_numerical.b    = lp_problem.Constraints.MatrixIneq ;
