% 'rba_model_schematic'
% ---------------------
%   .EntityType
%   .ElementType
%   .VariableType
%   .ParameterType
%   .Connection
%   .ModelConstraint
%  (each field represents a table from a model-schematic SBtab file)
%
% 'rba-model-components'
% ----------------------
%   .elements     struct with subfields
%      .[ELEMENTNAME].IDsymbol   (with ELEMENTNAMEs as defined in rba-model-schematic)
%   .variables    struct with subfields
%      .[VARIABLETYPE].LowerBound
%      .[VARIABLETYPE].UpperBound (with VARIABLETYPEs as defined in rba-model-schematic)
%   .connections: struct with fieldnames [CONNECTIONS], as defined in rba-model-schematic; each field contains a matrix
%
% 'rba-model-symbolic'
% -------------------------------------------------------
%   (a data container for convenience)   
%   .variables   : cell array with fields
%      .[VARIABLETYPE].ids                  list of variable ids in model
%      .[VARIABLETYPE].indices              list of variable indices in the final variable vector
%      .[VARIABLETYPE].variable_type_index  numbering index of variable type
%   .parameters   : cell array with fields
%      .[PARAMETERTYPE].ids                 list of parameter ids in model
%      .[PARAMETERTYPE].indices             list of parameter indices in the final parameter vector
%   .statements   : cell array with fields
%      .[STATEMENTTYPE].Name                statement name
%      .[STATEMENTTYPE].Variable            name of variable type concerned (on left-hand side)
%      .[STATEMENTTYPE].StatementType       type of statement
%      .[STATEMENTTYPE].RightHandSide       (only for some statement types): formula (symbolic) for right-hand side
%
% 'rba_problem_symbolic'
% ----------------------
%    (describing the symbolic RBA LP problem)
%    .variable_types      n x 1: names of variable types
%    .constraint_types_a  m x 1: cell array of equality constraint types
%    .constraint_types_b  p x 1: cell array of iequality constraint types
%    .x_lb                n x 1: cell array of lower bound symbols (eg '- Inf');
%    .x_ub                n x 1: cell array of upper bound symbols (eg '+ Inf');
%    .A{1,nn}             m x n: cell array of connection names (eg '+ Inf');
%    .B{1,nn}             p x n: cell array of connection names (eg '+ Inf');
%    .a                   m x 1: cell array of equality right hand sides
%    .b                   m x 1: cell array of inequality right hand sides
%   .. and additional fields for convenience:
%    .variable_indices    n x 1: indices of variable types
%    .constraint_number_a m x 1: vector of equality constraint numbers
%    .constraint_number_b p x 1: vector of inequality constraint numbers
%    
% 'rba_problem_numeric'
% ---------------------
%   (describing the numerical RBA LP problem)
%   .x_id    cell struct, variable ids
%   .a_eq_id cell struct, equality constraint ids
%   .b_in_id cell struct, inequality constraint ids
%   .x_lb    vector, lower bounds
%   .x_ub    vector, upper bounds
%   .A_eq    matrix in equality A x = a
%   .a_eq    vector in equality A x = a
%   .B_in    matrix in inequality B x = b
%   .b_in    vector in inequality B x = b
