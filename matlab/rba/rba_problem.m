% Matlab data structure for RBA models (parameterised LP problem)
% ---------------------------------------------------------------
%
% (1) Data structure with for RBA problems fixed matrices (growth rate cannot be changed)
%
% Simple LP feasibility_problem with ns = #(state variables), 
% ne = #(equality constraints), ni = #(ineqality constraints)
% 
% Data structure R:
%   R.Variables.Names:        {ns x 1 cell}
%   R.Variables.LowerBounds:  [ns x 1 double]
%   R.Variables.UpperBounds:  [ns x 1 double]
%   R.Constraints.NamesEq:    {ne x 1 cell}
%   R.Constraints.NamesIneq:  {ni x 1 cell}
%   R.Constraints.VectorEq:   [ne x 1 double]
%   R.Constraints.VectorIneq: [ni x 1 double]
%   R.Constraints.MatrixEq:   [ne x ns double]
%   R.Constraints.MatrixIneq: [ni x ns double]
%   R.Solution.StateVector:   [ns x 1 double]
%   R.Solution.Objective:     double
%
% The problem can be directly solved by linear porgramming (eg using linprog or cplexlp)
%
% (2) Data structure for RBA problems with parameterised matrices 
%       (e.g. for a definable growth rate or another variable parameter)
%
% We assume that the matrices R.Constraints are parameter-dependent, and of the form
%   Aeq = Aeq1 + p * Aeqp
%   Ain = Ain1 + p * Ainp
% where p is the parameter in question (e.g. the growth rate)
%
% In the data structure, the entries
%
%   R.Constraints.MatrixEq:   [ne x ns double]
%   R.Constraints.MatrixIneq: [ni x ns double]
%   R.Solution.Objective:     double
%
% are now replaced by entries
%
%   R.Constraints.MatrixEq_1:   [ne x ns double]
%   R.Constraints.MatrixEq_p:   [ne x ns double]
%   R.Constraints.MatrixIneq_1: [ni x ns double]
%   R.Constraints.MatrixIneq_p: [ni x ns double]
%   R.Solution.GrowthRate:      double
