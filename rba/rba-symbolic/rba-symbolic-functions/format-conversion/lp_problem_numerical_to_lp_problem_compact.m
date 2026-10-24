function lp_problem_compact = lp_problem_numerical_to_compact(lp_problem_numerical)
  
lp_problem_compact.col_names = lp_problem_numerical.id_x;
lp_problem_compact.row_names = [lp_problem_numerical.id_a; lp_problem_numerical.id_b];
lp_problem_compact.LB        = lp_problem_numerical.x_lb;
lp_problem_compact.UB        = lp_problem_numerical.x_ub;
lp_problem_compact.A         = full([lp_problem_numerical.A; lp_problem_numerical.B]);
lp_problem_compact.b         = full([lp_problem_numerical.a; lp_problem_numerical.b]);
lp_problem_compact.row_signs = [repmat({'E'},length(lp_problem_numerical.id_a),1); repmat({'L'},length(lp_problem_numerical.id_b),1)];
