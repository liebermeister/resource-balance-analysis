function [rba_model, rba_model_components] = rba_model_construct(rba_model_scheme, rba_model_components)

% rba_model = rba_model_construct(rba_model_scheme, rba_model_components)
% 
% build "rba-model" object from an "rba-model-scheme" and on element numbers and matrices for a cell model
% while completing missing information in 'rba_model_components'
  
rba_model = struct;
rba_model.TYPE        = 'rba-model-symbolic';
rba_model.variables   = [];
rba_model.parameters  = [];
rba_model.statements  = [];

variable_types  = rmfield(rba_model_scheme.VariableType,'TABLE_ATTRIBUTES');
parameter_types = rmfield(rba_model_scheme.ParameterType,'TABLE_ATTRIBUTES');
rba_problem     = rmfield(rba_model_scheme.ModelConstraints,'TABLE_ATTRIBUTES');

vt = fieldnames(variable_types);
pt = fieldnames(parameter_types);


% -----------------------------------------------------------------
% build field "variables:
% for each type of variable, put IDs and index number vectors into rba_model.variables
% -----------------------------------------------------------------

z = 0;
for it =1:length(vt),
  my_variable    = vt{it};
  my_element     = rba_model_scheme.VariableType.(my_variable).indexed_by;
  my_element_ids = rba_model_components.elements.(my_element).IDsymbol;
  if ~isfield(rba_model_components.variables,my_variable),
    error(sprintf('Variable "%s" required by the model scheme is not declared in rba-model-components file',my_variable));
  end
  if ~isfield(rba_model_components.variables.(my_variable),'LowerBound'),
    rba_model_components.variables.(my_variable).LowerBound = -inf * ones(size(my_element_ids));
  end
  if ~isfield(rba_model_components.variables.(my_variable),'UpperBound'),
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
  rba_model.variables.(vt{it}).ids = my_variable_ids;
  rba_model.variables.(vt{it}).indices = z + [1:my_number]';
  rba_model.variables.(vt{it}).variable_type_index = it;
  z = z + my_number;
end


% -----------------------------------------------------------------
% build field "parameters:
% for each type of parameter, put IDs and index number vectors into rba_model.variables
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
  rba_model.parameters.(pt{it}).ids = my_parameter_ids;
  rba_model.parameters.(pt{it}).indices = z + [1:my_number]';
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

% copy all existing statements from the model scheme table "ModelConstraints"

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
  my_dependency_string = variable_types.(vt{it}).is_given_by;
  my_rule = [];
  if length(my_dependency_string),
    my_formula = jsondecode(my_dependency_string);
    my_statement_ID = [vt{it} '_dependencies'];
    my_statement = [];
    my_statement.Name = [vt{it} ' dependence on other variables'];
    my_statement.Variable = vt{it};
    my_statement.StatementType = 'is_given_by';
    my_statement.RightHandSide = my_formula;
    if length(my_statement.RightHandSide),
      statements.(my_statement_ID) = my_statement;
    end
  end
end

rba_model.statements = statements;

