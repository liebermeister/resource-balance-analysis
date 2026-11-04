function [problems, warnings] = rba_model_schema_check(rba_model_schema, verbose)

% [problems, warnings] = rba_model_schema_check(rba_model_schema, verbose)
%
% Check a model schema (struct obtained from an SBtab file of DocumentType 'model-schema',
% see 'help rba-symbolic') for internal consistency.
%
% problems: cell array of error messages (the schema cannot be used as it is)
% warnings: cell array of warnings      (the schema can be used, but something looks wrong)
%
% verbose (default 1): print problems and warnings
%
% Checks:
%  o ElementType definitions refer to existing EntityTypes
%  o VariableTypes and ParameterTypes are indexed by existing ElementTypes
%  o IDsymbols of variable types (and of parameter types) are unique
%  o 'given_by' formulae are valid JSON, refer to existing variable types and to existing
%    connections, and each connection used goes from the input variable to the dependent variable
%  o Connections refer to existing variable types
%  o ModelConstraints refer to existing variable types and have a known StatementType
%  o 'is_diagonal_matrix_of' refers to an existing parameter type

eval(default('verbose','1'));

problems = {};
warnings = {};

entity_types    = table_ids(rba_model_schema, 'EntityType');
element_types   = table_ids(rba_model_schema, 'ElementType');
variable_types  = table_ids(rba_model_schema, 'VariableType');
parameter_types = table_ids(rba_model_schema, 'ParameterType');
connections     = table_ids(rba_model_schema, 'Connection');
constraints     = table_ids(rba_model_schema, 'ModelConstraint');

known_statement_types = {'is_equal_to_zero','is_lower_than_zero','is_higher_than_zero', ...
                         'is_equal_to_constant','is_lower_than_constant','is_higher_than_constant', ...
                         'is_equal_to_variable','is_lower_than_variable','is_higher_than_variable'};

% --- element types

for it = 1:length(element_types)
  my = rba_model_schema.ElementType.(element_types{it});
  if ~isfield(my,'Definition') || isempty(my.Definition), continue; end
  try
    definition = jsondecode(my.Definition);
  catch
    problems{end+1} = sprintf('ElementType %s: Definition is not valid JSON: %s', element_types{it}, my.Definition);
    continue
  end
  fn = fieldnames(definition);
  for itt = 1:length(fn)
    if ~ismember(definition.(fn{itt}), entity_types)
      problems{end+1} = sprintf('ElementType %s: unknown EntityType "%s"', element_types{it}, definition.(fn{itt}));
    end
  end
end

% --- variable types

symbols = {};
for it = 1:length(variable_types)
  my = rba_model_schema.VariableType.(variable_types{it});
  if ~ismember(my.indexed_by, element_types)
    problems{end+1} = sprintf('VariableType %s: indexed by unknown ElementType "%s"', variable_types{it}, my.indexed_by);
  end
  symbols{end+1} = my.IDsymbol;
  if isempty(my.given_by), continue; end
  try
    formula = jsondecode(my.given_by);
  catch
    problems{end+1} = sprintf('VariableType %s: given_by is not valid JSON: %s', variable_types{it}, my.given_by);
    continue
  end
  inputs = fieldnames(formula);
  for itt = 1:length(inputs)
    my_input = inputs{itt};
    my_term  = formula.(my_input);
    if ~ismember(my_input, variable_types)
      if regexp(my_input,'_\d+$')
        problems{end+1} = sprintf('VariableType %s: given_by contains a variable more than once (%s)', variable_types{it}, my.given_by);
      else
        problems{end+1} = sprintf('VariableType %s: given_by refers to unknown VariableType "%s"', variable_types{it}, my_input);
      end
      continue
    end
    [sign_ok, my_connection] = split_term(my_term);
    if ~sign_ok
      problems{end+1} = sprintf('VariableType %s: term "%s" must have the form "+ NAME" or "- NAME"', variable_types{it}, my_term);
      continue
    end
    if strcmp(my_connection,'I'), continue; end
    if ~ismember(my_connection, connections)
      problems{end+1} = sprintf('VariableType %s: given_by uses connection "%s", which is not declared in the Connection table', variable_types{it}, my_connection);
      continue
    end
    my_c = rba_model_schema.Connection.(my_connection);
    if ~strcmp(my_c.From, my_input) || ~strcmp(my_c.To, variable_types{it})
      problems{end+1} = sprintf('VariableType %s: connection %s is used from %s to %s, but declared from %s to %s', ...
                                variable_types{it}, my_connection, my_input, variable_types{it}, my_c.From, my_c.To);
    end
  end
end
duplicates = find_duplicates(symbols);
for it = 1:length(duplicates)
  problems{end+1} = sprintf('VariableType: IDsymbol "%s" is used more than once (variable IDs would not be unique)', duplicates{it});
end

% --- parameter types

symbols = {};
for it = 1:length(parameter_types)
  my = rba_model_schema.ParameterType.(parameter_types{it});
  if ~isempty(my.indexed_by) && ~ismember(my.indexed_by, element_types)
    problems{end+1} = sprintf('ParameterType %s: indexed by unknown ElementType "%s"', parameter_types{it}, my.indexed_by);
  end
  symbols{end+1} = my.IDsymbol;
end
duplicates = find_duplicates(symbols);
for it = 1:length(duplicates)
  problems{end+1} = sprintf('ParameterType: IDsymbol "%s" is used more than once', duplicates{it});
end

% --- connections

used_connections = {};
for it = 1:length(variable_types)
  my = rba_model_schema.VariableType.(variable_types{it});
  if isempty(my.given_by), continue; end
  try, formula = struct2cell(jsondecode(my.given_by)); catch, continue; end
  for itt = 1:length(formula)
    [~, my_connection] = split_term(formula{itt});
    used_connections{end+1} = my_connection;
  end
end

for it = 1:length(connections)
  my = rba_model_schema.Connection.(connections{it});
  if ~ismember(my.From, variable_types)
    problems{end+1} = sprintf('Connection %s: From refers to unknown VariableType "%s"', connections{it}, my.From);
  end
  if ~ismember(my.To, variable_types)
    problems{end+1} = sprintf('Connection %s: To refers to unknown VariableType "%s"', connections{it}, my.To);
  end
  if isfield(my,'is_diagonal_matrix_of') && ~isempty(my.is_diagonal_matrix_of) && ~ismember(my.is_diagonal_matrix_of, parameter_types)
    warnings{end+1} = sprintf('Connection %s: is_diagonal_matrix_of refers to unknown ParameterType "%s"', connections{it}, my.is_diagonal_matrix_of);
  end
  if ~ismember(connections{it}, used_connections)
    warnings{end+1} = sprintf('Connection %s is declared, but not used in any given_by formula', connections{it});
  end
end

% --- constraints

for it = 1:length(constraints)
  my = rba_model_schema.ModelConstraint.(constraints{it});
  if ~ismember(my.Variable, variable_types)
    problems{end+1} = sprintf('ModelConstraint %s: unknown VariableType "%s"', constraints{it}, my.Variable);
  end
  if ~ismember(my.StatementType, known_statement_types)
    problems{end+1} = sprintf('ModelConstraint %s: unknown StatementType "%s"', constraints{it}, my.StatementType);
  end
  if ~isempty(strfind(my.StatementType,'_variable')) && ~ismember(my.RightHandSide, variable_types)
    problems{end+1} = sprintf('ModelConstraint %s: RightHandSide refers to unknown VariableType "%s"', constraints{it}, my.RightHandSide);
  end
  if ~isempty(strfind(my.StatementType,'_constant')) && ~ismember(my.RightHandSide, parameter_types)
    problems{end+1} = sprintf('ModelConstraint %s: RightHandSide refers to unknown ParameterType "%s"', constraints{it}, my.RightHandSide);
  end
end

if verbose
  for it = 1:length(problems), fprintf('Schema problem: %s\n', problems{it}); end
  for it = 1:length(warnings), fprintf('Schema warning: %s\n', warnings{it}); end
end


% ------------------------------------------------------------

function ids = table_ids(rba_model_schema, table_name)

if isfield(rba_model_schema, table_name)
  ids = setdiff(fieldnames(rba_model_schema.(table_name)), {'TABLE_ATTRIBUTES'}, 'stable');
else
  ids = {};
end

function [ok, name] = split_term(term)

term = strtrim(term);
ok   = length(term) > 2 && any(strcmp(term(1:2), {'+ ','- '}));
name = strtrim(term(3:end));

function duplicates = find_duplicates(list)

[u, ~, j]  = unique(list);
duplicates = u(accumarray(j(:), 1) > 1);
