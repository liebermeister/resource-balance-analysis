function rba_problem_numerical = rba_make_linear_problem_numerical(rba_problem_symbolic, rba_model_indices, rba_model_components)

% rba_problem_numerical = rba_make_linear_problem_numerical(rba_problem_symbolic, rba_model_indices)
%
% Translate 'rba_problem_symbolic' into 'rba_problem_numerical' struct, using information
% (variable IDs, bounds, parameter values, and connection matrices) from 'rba_model_indices'
% (argument 'rba_model_components' is not used and only kept for compatibility)
%
% Note the variable names A, a, B, b denoting constraints
%  A x == a
%  B x <= b
%
% Constraint IDs are built from the constraint type and the element IDs of the constrained variable
%
% For data structure 'rba_problem_numerical', see 'help rba-symbolic'

LP_symbolic = rba_problem_symbolic;
variables   = rba_model_indices.variables;
names_x     = LP_symbolic.names_x;

% -----------------------------------------------------------------
% collect ids and bounds for all variables x in id_x, x_lb, and x_ub
% -----------------------------------------------------------------

id_x = {};
x_lb = [];
x_ub = [];

for it = 1:length(names_x)
  my_x_type = names_x{it};
  my_x_n    = length(variables.(my_x_type).ids);
  my_x_lb   = symbolic_bound(LP_symbolic.x_lb{it}, my_x_n, rba_model_indices, my_x_type);
  my_x_ub   = symbolic_bound(LP_symbolic.x_ub{it}, my_x_n, rba_model_indices, my_x_type);
  %% join the bounds required by the schema with bounds given in
  %% model-components, by using the stricter value in each case
  my_x_lb   = max([my_x_lb, variables.(my_x_type).LowerBound],[],2);
  my_x_ub   = min([my_x_ub, variables.(my_x_type).UpperBound],[],2);
  id_x      = [id_x; variables.(my_x_type).ids];
  x_lb      = [x_lb; my_x_lb];
  x_ub      = [x_ub; my_x_ub];
end

if any(x_lb > x_ub)
  ind = find(x_lb > x_ub);
  warning('rba_make_linear_problem_numerical:bounds', 'Lower bound exceeds upper bound for variable(s): %s', strjoin(id_x(ind)', ', '));
end

n_x = length(id_x);

% -----------------------------------------------------------------
% equality constraints (A, a) and inequality constraints (B, b)
% -----------------------------------------------------------------

[A, a, id_a] = build_constraints(LP_symbolic.names_a, LP_symbolic.constrained_variable_a, LP_symbolic.A, LP_symbolic.a, names_x, n_x, rba_model_indices);
[B, b, id_b] = build_constraints(LP_symbolic.names_b, LP_symbolic.constrained_variable_b, LP_symbolic.B, LP_symbolic.b, names_x, n_x, rba_model_indices);

rba_problem_numerical = struct;
rba_problem_numerical.id_x = id_x;
rba_problem_numerical.id_a = id_a;
rba_problem_numerical.id_b = id_b;
rba_problem_numerical.x_lb = x_lb;
rba_problem_numerical.x_ub = x_ub;
rba_problem_numerical.A    = sparse(A);
rba_problem_numerical.a    = a;
rba_problem_numerical.B    = sparse(B);
rba_problem_numerical.b    = b;


% =================================================================

function [M, m, id_m] = build_constraints(names, constrained_variables, M_symbolic, m_symbolic, names_x, n_x, rba_model_indices)

variables = rba_model_indices.variables;
M    = zeros(0, n_x);
m    = zeros(0, 1);
id_m = {};

for it = 1:length(names)
  my_constraint_type = names{it};
  my_variable_type   = constrained_variables{it};
  my_element_ids     = variables.(my_variable_type).element_ids;
  my_n               = length(my_element_ids);
  my_ids             = cellfun(@(e) [my_constraint_type '_' e], my_element_ids, 'UniformOutput', false);

  % right-hand side
  my_rhs_string = m_symbolic{it};
  if isempty(my_rhs_string) || strcmp(my_rhs_string,'0')
    my_m = zeros(my_n,1);
  else
    [my_sign, my_name] = split_term(my_rhs_string);
    my_m = my_sign * parameter_values(rba_model_indices, my_name, my_n);
  end

  % matrix blocks
  my_M_row = zeros(my_n, n_x);
  for itt = 1:length(names_x)
    my_x_type       = names_x{itt};
    my_x_indices    = variables.(my_x_type).indices;
    my_block_string = M_symbolic{it,itt};
    if isempty(my_block_string) || strcmp(my_block_string,'0'), continue; end
    [my_sign, my_matrix_string] = split_term(my_block_string);
    switch my_matrix_string
      case 'I'
        if length(my_x_indices) ~= my_n
          error(sprintf('Constraint %s: identity matrix between variables %s and %s of different sizes', my_constraint_type, my_variable_type, my_x_type));
        end
        my_block = eye(my_n);
      otherwise
        if ~isfield(rba_model_indices.connections, my_matrix_string)
          error(sprintf('Constraint %s: connection matrix %s not found', my_constraint_type, my_matrix_string));
        end
        my_block = rba_model_indices.connections.(my_matrix_string);
    end
    my_M_row(:,my_x_indices) = my_M_row(:,my_x_indices) + my_sign * my_block;
  end

  M    = [M; my_M_row];
  m    = [m; my_m];
  id_m = [id_m; my_ids];
end


% -----------------------------------------------------------------

function x = symbolic_bound(bound_string, n, rba_model_indices, my_x_type)

% translate a symbolic bound ('0', '- Inf', '+ Inf', or a parameter type name) into numbers

s = lower(strrep(strtrim(bound_string),' ',''));
switch s
  case {'0'},                 x = zeros(n,1);
  case {'-inf'},              x = -inf * ones(n,1);
  case {'inf','+inf'},        x =  inf * ones(n,1);
  otherwise
    if isfield(rba_model_indices.parameters, bound_string)
      x = parameter_values(rba_model_indices, bound_string, n);
    else
      error(sprintf('Variable type %s: cannot interpret bound "%s"', my_x_type, bound_string));
    end
end


% -----------------------------------------------------------------

function v = parameter_values(rba_model_indices, my_parameter, n)

if ~isfield(rba_model_indices.parameters, my_parameter)
  error(sprintf('Unknown parameter type %s', my_parameter));
end
v = rba_model_indices.parameters.(my_parameter).values;
if any(isnan(v))
  error(sprintf('Values for parameter type %s are needed, but missing in model components', my_parameter));
end
if length(v) == 1, v = v * ones(n,1); end
if length(v) ~= n
  error(sprintf('Parameter type %s has %d values, but %d are needed', my_parameter, length(v), n));
end


% -----------------------------------------------------------------

function [my_sign, name] = split_term(term)

term = strtrim(term);
if length(term) < 3, error(sprintf('Term "%s" in RBA dependency formula must have the form "[sign] [matrixname]"', term)); end
switch term(1:2)
  case '+ ', my_sign =  1;
  case '- ', my_sign = -1;
  otherwise, error(sprintf('Term "%s" in RBA dependency formula must have the form "[sign] [matrixname]"', term));
end
name = strtrim(term(3:end));
