% ========================================
% Data structures used in the RBA workflow
% ========================================
%
% ------------------------------------
% Data structure 'rba-model-schema' (describing the form of the rba model)
%
%  struct with fields
%   .EntityType
%   .ElementType
%   .VariableType
%   .ParameterType
%   .Connection
%   .ModelConstraint
%
% In SBtab (SBtab format "model-schema"), each field represents one table 
% Conversion to SBtab (files in directory /resources/model-schema)
%   o conversion from SBtab: sbtab_to_struct(rba_model_schema_sbtab,'row')
%   o conversion to SBtab:   struct_to_sbtab(rba_model_schema)
%
% -------------------------------------
% Data structure 'rba-model-components' (describing the specific cell type)
%
%  struct with fields
%   .entities : [OPTIONAL] struct
%      .[ENTITYTYPE].Name        (with ELEMENTNAMEs as defined in rba-model-schema)
%      .[ENTITYTYPE].Annotation  (with ELEMENTNAMEs as defined in rba-model-schema)
%   .elements : struct
%      .[ELEMENTTYPE].IDsymbol   (with ELEMENTNAMEs as defined in rba-model-schema)
%   .variables : [OPTIONAL] struct
%      .[VARIABLETYPE].LowerBound
%      .[VARIABLETYPE].UpperBound (with VARIABLETYPEs as defined in rba-model-schema)
%   .connections : struct
%      .[CONNECTIONS], as defined in rba-model-schema; each field contains a matrix
%
%  In SBtab (Document type model-component), each subfield represents one table 
%  currently defined by scripts (in subdirectory "example-functions")
%
% -----------------------------------
% Data structure 'rba-model-indices' (data container used within matlab for convenience)   
%
%  struct with fields
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
% -------------------------------------
% Data structure 'linear-problem-symbolic' (describing the symbolic RBA LP problem)
%
%  struct with fields
%    .names_x             nx x 1: names of variable types
%    .names_a             na x 1: cell array of equality constraint types
%    .names_b             nb x 1: cell array of iequality constraint types
%    .x_lb                nx x 1: cell array of lower bound symbols (eg '- Inf');
%    .x_ub                nx x 1: cell array of upper bound symbols (eg '+ Inf');
%    .A                   na x nx: cell array of connection names (eg '+ Inf');
%    .B                   nb x nx: cell array of connection names (eg '+ Inf');
%    .a                   na x 1: cell array of equality right hand sides
%    .b                   nb x 1: cell array of inequality right hand sides
%    
% ------------------------------------
% Data structure 'linear-problem-numerical' (describing the numerical RBA LP problem)
%
%  struct with fields
%   .id_x  cell struct, variable ids
%   .id_a  cell struct, equality constraint ids
%   .id_b  cell struct, inequality constraint ids
%   .x_lb  vector, lower bounds
%   .x_ub  vector, upper bounds
%   .A     matrix A in equality A x = a
%   .a     vector a in equality A x = a
%   .B     matrix B in inequality B x <= b
%   .b     vector b in inequality B x <= b
%
%
% ------------------------------------
% Data structure 'linear-problem-compact' (Format used for data exchange with RBApy tool)
%  (alternative format for numerical LP problems, equivalent to 'rba-problem-numerical')
%
%  struct with fields
%   .row_names  cell struct, variable ids
%   .col_names  cell struct, constraint ids
%   .LB         vector, lower bounds
%   .UB         vector, upper bounds
%   .A          matrix A in constraints
%   .b          vector b in constraints
%   .row_signs  cell struct with entries "E" (equality) "L" (lower than) denoting the types of constraints
