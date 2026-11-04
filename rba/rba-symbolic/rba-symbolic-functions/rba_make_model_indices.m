function rba_model_indices = rba_make_model_indices(rba_model_schema, rba_model_components)

% rba_model_indices = rba_make_model_indices(rba_model_schema, rba_model_components)
%
% Build 'rba-model-indices' struct from 'rba-model-schema' and 'rba-model-components' structs
% The 'rba-model-indices' struct contains some information in a more ordered way:
% variable and parameter IDs, their positions in the variable and parameter vectors,
% bounds, parameter values, connection matrices, and all statements (constraints)
%
% For the data structures, see 'help rba-symbolic'
%
% Parameter values (optional) are read from rba_model_components.Parameter.[PARAMETERTYPE].Value
% (vector, or scalar for parameters that are not indexed); missing values are set to NaN.
%
% Connection matrices are taken from rba_model_components.Connection; if a connection matrix
% is missing, but the connection is declared in the schema as 'is_diagonal_matrix_of' a parameter
% whose values are given, the matrix is constructed as diag(parameter values) (or, for a scalar
% parameter, as parameter value * identity matrix).

% -----------------------------------------------------------------
% check schema

problems = rba_model_schema_check(rba_model_schema, 0);
if length(problems)
  error(sprintf('The model schema is inconsistent:\n  %s', strjoin(problems, sprintf('\n  '))));
end

rba_model_indices = struct;
rba_model_indices.TYPE        = 'rba-model-indices';
rba_model_indices.variables   = [];
rba_model_indices.parameters  = [];
rba_model_indices.connections = struct;
rba_model_indices.statements  = [];

variable_types  = rmfield(rba_model_schema.VariableType,'TABLE_ATTRIBUTES');
parameter_types = rmfield(rba_model_schema.ParameterType,'TABLE_ATTRIBUTES');
connections     = rmfield(rba_model_schema.Connection,'TABLE_ATTRIBUTES');
model_constraints = rmfield(rba_model_schema.ModelConstraint,'TABLE_ATTRIBUTES');

vt = fieldnames(variable_types);
pt = fieldnames(parameter_types);

if ~isfield(rba_model_components,'Variable'),   rba_model_components.Variable   = struct; end
if ~isfield(rba_model_components,'Parameter'),  rba_model_components.Parameter  = struct; end
if ~isfield(rba_model_components,'Connection'), rba_model_components.Connection = struct; end


% -----------------------------------------------------------------
% build field "variables":
% for each type of variable, put IDs and index number vectors into rba_model_indices.variables
% -----------------------------------------------------------------

z = 0;

for it = 1:length(vt)
  my_variable    = vt{it};
  my_element     = variable_types.(my_variable).indexed_by;
  my_element_ids = get_element_ids(rba_model_components, my_element, ['variable type ' my_variable]);
  my_number      = length(my_element_ids);

  % complete missing upper and lower bounds
  if ~isfield(rba_model_components.Variable,my_variable)
    rba_model_components.Variable.(my_variable) = struct('LowerBound',[],'UpperBound',[]);
  end
  my_bounds = rba_model_components.Variable.(my_variable);
  if ~isfield(my_bounds,'LowerBound') || isempty(my_bounds.LowerBound), my_bounds.LowerBound = -inf * ones(my_number,1); end
  if ~isfield(my_bounds,'UpperBound') || isempty(my_bounds.UpperBound), my_bounds.UpperBound =  inf * ones(my_number,1); end
  if length(my_bounds.LowerBound) ~= my_number
    error(sprintf('Wrong number of lower bounds given for variable type %s', my_variable));
  end
  if length(my_bounds.UpperBound) ~= my_number
    error(sprintf('Wrong number of upper bounds given for variable type %s', my_variable));
  end

  my_variable_ids = cell(my_number,1);
  for itt = 1:my_number
    my_variable_ids{itt,1} = [ variable_types.(my_variable).IDsymbol '_' my_element_ids{itt}];
  end
  rba_model_indices.variables.(my_variable).ids                 = my_variable_ids;
  rba_model_indices.variables.(my_variable).element_ids         = my_element_ids;
  rba_model_indices.variables.(my_variable).indices             = z + [1:my_number]';
  rba_model_indices.variables.(my_variable).variable_type_index = it;
  rba_model_indices.variables.(my_variable).LowerBound          = to_double(my_bounds.LowerBound);
  rba_model_indices.variables.(my_variable).UpperBound          = to_double(my_bounds.UpperBound);
  z = z + my_number;
end


% -----------------------------------------------------------------
% build field "parameters":
% for each type of parameter, put IDs, index number vectors, and values into rba_model_indices.parameters
% -----------------------------------------------------------------

z = 0;
for it = 1:length(pt)
  my_parameter = pt{it};
  my_element   = parameter_types.(my_parameter).indexed_by;
  if length(my_element)
    my_element_ids   = get_element_ids(rba_model_components, my_element, ['parameter type ' my_parameter]);
    my_number        = length(my_element_ids);
    my_parameter_ids = cell(my_number,1);
    for itt = 1:my_number
      my_parameter_ids{itt,1} = [ parameter_types.(my_parameter).IDsymbol '_' my_element_ids{itt}];
    end
  else
    my_number        = 1;
    my_parameter_ids = {parameter_types.(my_parameter).IDsymbol};
  end
  my_values = nan * ones(my_number,1);
  if isfield(rba_model_components.Parameter, my_parameter)
    my_values = to_double(rba_model_components.Parameter.(my_parameter).Value);
    if length(my_values) == 1, my_values = my_values * ones(my_number,1); end
    if length(my_values) ~= my_number
      error(sprintf('Wrong number of values given for parameter type %s', my_parameter));
    end
  end
  rba_model_indices.parameters.(my_parameter).ids     = my_parameter_ids;
  rba_model_indices.parameters.(my_parameter).indices = z + [1:my_number]';
  rba_model_indices.parameters.(my_parameter).values  = my_values;
  z = z + my_number;
end


% -----------------------------------------------------------------
% build field "connections":
% collect the connection matrices used in the schema and check their sizes
% -----------------------------------------------------------------

used_connections = {};
for it = 1:length(vt)
  my_dependency_string = variable_types.(vt{it}).given_by;
  if length(my_dependency_string)
    terms = struct2cell(jsondecode(my_dependency_string));
    for itt = 1:length(terms)
      used_connections{end+1} = strtrim(terms{itt}(3:end));
    end
  end
end
used_connections = setdiff(unique(used_connections), {'I'});

for it = 1:length(used_connections)
  my_connection = used_connections{it};
  my_from = connections.(my_connection).From;
  my_to   = connections.(my_connection).To;
  n_from  = length(rba_model_indices.variables.(my_from).ids);
  n_to    = length(rba_model_indices.variables.(my_to).ids);
  if isfield(rba_model_components.Connection, my_connection)
    my_matrix = full(rba_model_components.Connection.(my_connection));
  elseif isfield(connections.(my_connection),'is_diagonal_matrix_of') && length(connections.(my_connection).is_diagonal_matrix_of)
    my_parameter = connections.(my_connection).is_diagonal_matrix_of;
    my_values    = rba_model_indices.parameters.(my_parameter).values;
    if any(isnan(my_values))
      error(sprintf('Connection matrix %s is missing in model components; it could be computed from parameter %s, but the parameter values are missing', my_connection, my_parameter));
    end
    if n_from ~= n_to
      error(sprintf('Connection matrix %s (diagonal matrix of %s) must be square, but variables %s and %s have different sizes', my_connection, my_parameter, my_from, my_to));
    end
    if length(my_values) == 1
      my_matrix = my_values * eye(n_to);
    elseif length(my_values) == n_to
      my_matrix = diag(my_values);
    else
      error(sprintf('Connection matrix %s: parameter %s has %d values, but the matrix has size %d', my_connection, my_parameter, length(my_values), n_to));
    end
  else
    error(sprintf('Connection matrix %s (used in the model schema) is missing in model components', my_connection));
  end
  if size(my_matrix,1) ~= n_to || size(my_matrix,2) ~= n_from
    error(sprintf('Wrong size (%d x %d) of connection matrix %s with input %s and output %s; expected size %d x %d', ...
                  size(my_matrix,1), size(my_matrix,2), my_connection, my_from, my_to, n_to, n_from));
  end
  rba_model_indices.connections.(my_connection) = my_matrix;
end

unused = setdiff(setdiff(fieldnames(rba_model_components.Connection),{'TABLE_ATTRIBUTES'}), used_connections);
if length(unused)
  warning('rba_make_model_indices:unused_connections', 'Connection matrices in model components not used by the schema: %s', strjoin(unused', ', '));
end


% -----------------------------------------------------------------
% build field "statements"
% -----------------------------------------------------------------

% copy all existing statements from the model schema table "ModelConstraint"

statements = model_constraints;

% add positivity statements for all variables supposed to be nonnegative

for it = 1:length(vt)
  if strcmp(variable_types.(vt{it}).nonnegative,'True')
    my_statement = struct;
    my_statement.Name = [vt{it} '_positivity'];
    my_statement.Variable = vt{it};
    my_statement.StatementType = 'is_higher_than_zero';
    statements.(my_statement.Name) = my_statement;
  end
end

% add dependence statements for all variables supposed to be determined by others

for it = 1:length(vt)
  my_dependency_string = variable_types.(vt{it}).given_by;
  if length(my_dependency_string)
    my_formula = jsondecode(my_dependency_string);
    my_statement_ID = [vt{it} '_dependencies'];
    my_statement = struct;
    my_statement.Name = [vt{it} ' dependence on other variables'];
    my_statement.Variable = vt{it};
    my_statement.StatementType = 'given_by';
    my_statement.RightHandSide = my_formula;
    statements.(my_statement_ID) = my_statement;
  end
end

rba_model_indices.statements = statements;


% -----------------------------------------------------------------

function my_element_ids = get_element_ids(rba_model_components, my_element, context)

if ~isfield(rba_model_components.Element, my_element)
  error(sprintf('Information about element type %s (used by %s in the model schema) is missing in model components', my_element, context));
end
my_element_ids = column(rba_model_components.Element.(my_element).IDsymbol);

function x = to_double(x)

if iscell(x)
  x = cellfun(@(e) double_value(e), x);
end
x = double(x(:));

function v = double_value(e)

if ischar(e), v = str2double(e); else, v = double(e); end
