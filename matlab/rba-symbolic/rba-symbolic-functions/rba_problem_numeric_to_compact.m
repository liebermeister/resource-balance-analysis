function rba_problem_compact = rba_problem_numeric_to_compact(rba_problem_numeric)
  
rba_problem_compact.col_names = rba_problem_numeric.id_x;
rba_problem_compact.row_names = [rba_problem_numeric.id_a; rba_problem_numeric.id_b];
rba_problem_compact.LB        = rba_problem_numeric.x_lb;
rba_problem_compact.UB        = rba_problem_numeric.x_ub;
rba_problem_compact.A         = full([rba_problem_numeric.A; rba_problem_numeric.B]);
rba_problem_compact.b         = full([rba_problem_numeric.a; rba_problem_numeric.b]);
rba_problem_compact.row_signs = [repmat({'E'},length(rba_problem_numeric.id_a),1); repmat({'L'},length(rba_problem_numeric.id_a),1)];
