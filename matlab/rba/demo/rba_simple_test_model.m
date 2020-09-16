% ------------------------------------------
% simple test model

k = 1;
d = 1;

n_eq   = 1;
n_ineq = 2;

% here: A and a for eq, B and b for ineq!

A_1 = [1 0];
A_p = [0, -1];
B_1 = [1, -k; 0, 1];
B_p = [0, 0; 0, 0];
a   = 0;
b   = [0; d];

x_ref      = [1 1]'; % invented
lambda_ref = 1;      % invented

% ------------------------------------------
% conversion to matlab RBA dataformat

rba_problem.Variables.Names          = {'x1','x2'};    
rba_problem.Variables.LowerBounds    = [0 0]';    
rba_problem.Variables.UpperBounds    = [1 1]';
rba_problem.Constraints.NamesEq      = {'eq1'};  
rba_problem.Constraints.NamesIneq    = {'eq1','eq2'};  
rba_problem.Constraints.VectorEq     = a;     
rba_problem.Constraints.VectorIneq   = b;   
rba_problem.Constraints.MatrixEq_1   = A_1;   
rba_problem.Constraints.MatrixEq_p   = A_p;   
rba_problem.Constraints.MatrixIneq_1 = B_1; 
rba_problem.Constraints.MatrixIneq_p = B_p; 
