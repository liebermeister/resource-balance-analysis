function constraints = rba_set_parameter_dependent_matrices(constraints,p)
  
  constraints.MatrixEq   = constraints.MatrixEq_1   + p * constraints.MatrixEq_p;
  constraints.MatrixIneq = constraints.MatrixIneq_1 + p * constraints.MatrixIneq_p;
