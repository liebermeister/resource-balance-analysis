function rba_model_schema_draw_dependencies(rba_model_schema)

% rba_model_schema_draw_dependencies(rba_model_schema)
%
% Draw the dependencies between variable types in a model schema as a graph
%  o thick edges (labelled by the connection matrix): connections ("given_by" dependencies)
%  o thin edges: constraints between two variable types (e.g. flux <= maximal flux)
%  o thin self-edges: constraints on a single variable type (e.g. mass balance = 0)

variable_types = setdiff(fieldnames(rba_model_schema.VariableType),{'TABLE_ATTRIBUTES'},'stable');
connections    = setdiff(fieldnames(rba_model_schema.Connection),{'TABLE_ATTRIBUTES'},'stable');
constraints    = setdiff(fieldnames(rba_model_schema.ModelConstraint),{'TABLE_ATTRIBUTES'},'stable');

s       = [];
t       = [];
weights = [];
labels  = {};

for it = 1:length(connections)
  my_connection = rba_model_schema.Connection.(connections{it});
  ind_from = find(strcmp(my_connection.From, variable_types));
  ind_to   = find(strcmp(my_connection.To,   variable_types));
  if isempty(ind_from) || isempty(ind_to)
    error(sprintf('Connection %s refers to unknown variable type', connections{it}));
  end
  s(end+1) = ind_from; t(end+1) = ind_to; weights(end+1) = 2;
  labels{end+1} = my_connection.MathSymbol;
end

for it = 1:length(constraints)
  my_constraint = rba_model_schema.ModelConstraint.(constraints{it});
  ind_variable  = find(strcmp(my_constraint.Variable, variable_types));
  if isempty(ind_variable)
    error(sprintf('Constraint %s refers to unknown variable type', constraints{it}));
  end
  ind_rhs = find(strcmp(my_constraint.RightHandSide, variable_types));
  if isempty(ind_rhs), ind_rhs = ind_variable; end
  s(end+1) = ind_rhs; t(end+1) = ind_variable; weights(end+1) = 1;
  labels{end+1} = '';
end

% check for redundant edges
[~, ind_unique] = unique([s' t'], 'rows', 'stable');
if length(ind_unique) < length(s)
  ind_dup = setdiff(1:length(s), ind_unique);
  warning('Redundant dependencies in schema file (drawn only once): %s', ...
          strjoin(cellfun(@(a,b) [a ' -> ' b], variable_types(s(ind_dup)), variable_types(t(ind_dup)), 'UniformOutput', false)', ', '));
  s = s(ind_unique); t = t(ind_unique); weights = weights(ind_unique); labels = labels(ind_unique);
end

% build the graph from an edge table, so that the edge labels stay attached to the right edges
% (digraph sorts the edges)
edge_table = table([s' t'], weights', labels', 'VariableNames', {'EndNodes','Weight','Label'});
G = digraph(edge_table, table(strrep(variable_types,'_',' '), 'VariableNames', {'Name'}));
p = plot(G, 'Layout', 'layered', 'EdgeLabel', G.Edges.Label);
p.LineWidth = 1 + 2*(G.Edges.Weight-1);

xlabel('Thick edges: connections. Thin edges: constraints. Thin self-edges: constraints on one variable type');
