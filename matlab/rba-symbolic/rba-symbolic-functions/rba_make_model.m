function rba_model_indices = rba_make_model(rba_model_scheme, rba_model_components)

% rba_model_indices = rba_make_model(rba_model_scheme, rba_model_components)
% 
% build "rba-model" struct from "rba-model-schematic" and "rba-model-components" structs
% "rba-model" struct contains some information in a more ordered way
%
% for data structure 'rba-model-symbolic', see 'help rba-symbolic'
  
rba_model_indices = struct;
rba_model_indices.TYPE        = 'rba-model-symbolic';
rba_model_indices.variables   = [];
rba_model_indices.parameters  = [];
rba_model_indices.statements  = [];

variable_types  = rmfield(rba_model_scheme.VariableType,'TABLE_ATTRIBUTES');
parameter_types = rmfield(rba_model_scheme.ParameterType,'TABLE_ATTRIBUTES');
rba_problem     = rmfield(rba_model_scheme.ModelConstraint,'TABLE_ATTRIBUTES');

vt = fieldnames(variable_types);
pt = fieldnames(parameter_types);


% -----------------------------------------------------------------
% build field "variables:
% for each type of variable, put IDs and index number vectors into rba_model_indices.variables
% -----------------------------------------------------------------

z = 0;

for it =1:length(vt),
  my_variable    = vt{it};
  my_element     = rba_model_scheme.VariableType.(my_variable).indexed_by;
  if ~isfield(rba_model_components.elements,my_element),
    error(sprintf('Information about element type %s missing in model components file', my_element));
  end    
  my_element_ids = rba_model_components.elements.(my_element).IDsymbol;
  % Complete missing upper and lower bounds
  if ~isfield(rba_model_components,'variables'),
    rba_model_components.variables = struct;
  end
  if ~isfield(rba_model_components.variables,my_variable),
    rba_model_components.variables.(my_variable) = struct('LowerBound',[],'UpperBound',[]);
  end
  if isempty(rba_model_components.variables.(my_variable).LowerBound)
    rba_model_components.variables.(my_variable).LowerBound = -inf * ones(size(my_element_ids));
  end
  if isempty(rba_model_components.variables.(my_variable).UpperBound)
    rba_model_components.variables.(my_variable).UpperBound = inf * ones(size(my_element_ids));
  end
  if length(rba_model_components.variables.(my_variable).LowerBound) ~= length(my_element_ids),
    error(sprintf('Wrong number of lower bounds given for variable type %s', my_variable));
  end
  if length(rba_model_components.variables.(my_variable).UpperBound) ~= length(my_element_ids),
    error(sprintf('Wrong number of upper bounds given for variable type %s', my_variable));
  end
  my_number      = length(my_element_ids);
  my_variable_ids = [];
  for itt = 1:length(my_element_ids)
    my_variable_ids{itt,1} = [ rba_model_scheme.VariableType.(my_variable).IDsymbol '_' my_element_ids{itt}];
  end
  rba_model_indices.variables.(vt{it}).ids = my_variable_ids;
  rba_model_indices.variables.(vt{it}).indices = z + [1:my_number]';
  rba_model_indices.variables.(vt{it}).variable_type_index = it;
  rba_model_indices.variables.(vt{it}).LowerBound = rba_model_components.variables.(my_variable).LowerBound;
  rba_model_indices.variables.(vt{it}).UpperBound = rba_model_components.variables.(my_variable).UpperBound;
  z = z + my_number;
end


% -----------------------------------------------------------------
% build field "parameters:
% for each type of parameter, put IDs and index number vectors into rba_model_indices.variables
% -----------------------------------------------------------------

z = 0;
for it =1:length(pt),
  my_parameter   = pt{it};
  my_element     = rba_model_scheme.ParameterType.(my_parameter).indexed_by;
  if length(my_element),
    my_element_ids = rba_model_components.elements.(my_element).IDsymbol;
    my_number      = length(my_element_ids);
    my_parameter_ids = [];
    for itt = 1:length(my_element_ids)
      my_parameter_ids{itt,1} = [ rba_model_scheme.ParameterType.(my_parameter).IDsymbol '_' my_element_ids{itt}];
    end
  else
    my_number      = 1;
    my_parameter_ids = {rba_model_scheme.ParameterType.(my_parameter).IDsymbol};
  end
  rba_model_indices.parameters.(pt{it}).ids = my_parameter_ids;
  rba_model_indices.parameters.(pt{it}).indices = z + [1:my_number]';
  z = z + my_number;
end


% -----------------------------------------------------------------
% check matrix sizes in rba_model_components.connections
% -----------------------------------------------------------------

ct = fieldnames(rba_model_components.connections);
for it = 1:length(ct),
  my_connection = ct{it};
  my_connection_size = size(rba_model_components.connections.(my_connection));
  if ~isfield(rba_model_scheme.Connection,my_connection),
    error(sprintf('Model scheme: connection "%s" mentioned VariableType table is not declared in Connection table',my_connection));
  end
  my_connection_from = rba_model_scheme.Connection.(my_connection).From;
  my_connection_to   = rba_model_scheme.Connection.(my_connection).To;
  if ~isfield(rba_model_components.variables,my_connection_from),
    error(sprintf('Model scheme: variable "%s" mentioned in Connection table is not declared in VariableType table',my_connection_from));
  end
  if ~isfield(rba_model_components.variables,my_connection_to),
    error(sprintf('Model scheme: variable "%s" mentioned in Connection table is not declared in VariableType table',my_connection_to));
  end
  my_connection_size_from = length(rba_model_components.variables.(my_connection_from).LowerBound);
  my_connection_size_to   = length(rba_model_components.variables.(my_connection_to).LowerBound);
  if [my_connection_size_to ~= my_connection_size(1)] + [my_connection_size_from ~= my_connection_size(2)], 
    error(sprintf('Wrong matrix size in connection matrix %s with input %s and output %s',my_connection,my_connection_from, my_connection_to)); 
  end 
end

% -----------------------------------------------------------------
% build field "statements"
% -----------------------------------------------------------------

% copy all existing statements from the model schema table "ModelConstraint"

statements = rba_problem; 

% add positivity statements for all variables supposed to be nonnegative

for it =1:length(vt),
  if strcmp(variable_types.(vt{it}).nonnegative,'True'),
    my_statement = struct;
    my_statement.Name = [vt{it} '_positivity'];
    my_statement.Variable = vt{it};
    my_statement.StatementType = 'is_higher_than_zero';
    statements.(my_statement.Name) = my_statement;
  end
end

% add dependence statements for all variables supposed to be determined by others

for it =1:length(vt),
  my_dependency_string = variable_types.(vt{it}).given_by;
  my_rule = [];
  if length(my_dependency_string),
    my_formula = jsondecode(my_dependency_string);
    my_statement_ID = [vt{it} '_dependencies'];
    my_statement = [];
    my_statement.Name = [vt{it} ' dependence on other variables'];
    my_statement.Variable = vt{it};
    my_statement.StatementType = 'given_by';
    my_statement.RightHandSide = my_formula;
    if length(my_statement.RightHandSide),
      statements.(my_statement_ID) = my_statement;
    end
  end
end

rba_model_indices.statements = statements;

