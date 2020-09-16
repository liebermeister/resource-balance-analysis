function rba_model_schema_draw_dependencies(rba_model_schema)

variable_types = setdiff(fieldnames(rba_model_schema.VariableType),{'TABLE_ATTRIBUTES'});
connections    = setdiff(fieldnames(rba_model_schema.Connection),{'TABLE_ATTRIBUTES'});
A = sparse(zeros(length(variable_types)));

eLabels = {};
for it=1:length(connections),
  my_connection = rba_model_schema.Connection.(connections{it});
  my_from = my_connection.From;
  my_to   = my_connection.To;
  ind_from = find(strcmp(my_from,variable_types));
  ind_to   = find(strcmp(my_to,  variable_types));
  if isempty(ind_to)
    connections{it}
    my_to
    error('Connection refers to unknown variable type (to)');
  end
  if length(ind_from)*length(ind_from) == 0,
    connections{it}
    error('Connection refers to unknown variable type (from)');
  end
  if A(ind_from,ind_to)~=0,
    connections{it}
    error('Redundant dependency in schema file');
  end
  A(ind_from,ind_to) = 2;
  eLabels = [eLabels,{my_connection.MathSymbol}];
end

constraints = setdiff(fieldnames(rba_model_schema.ModelConstraint),{'TABLE_ATTRIBUTES'});
for it=1:length(constraints),
  my_constraint = rba_model_schema.ModelConstraint.(constraints{it});
  my_variable = my_constraint.Variable;
  my_rhs      = my_constraint.RightHandSide;
  ind_variable = find(strcmp(my_variable,variable_types));
  ind_rhs   = find(strcmp(my_rhs,  variable_types));
  if length(ind_variable) == 0,
    constraints{it}
    error('Constraint refers to unknown variable type');
  end
  edge_weight = 1;
  if isempty(ind_rhs), ind_rhs = ind_variable; edge_weight=1; end
  if A(ind_rhs,ind_variable)~=0,
    my_constraint
    error('Redundant dependency in schema file');
  end
  A(ind_rhs,ind_variable) = edge_weight;
  eLabels = [eLabels,{''}];
end

G = digraph(A,strrep(variable_types,'_',' '));
p = plot(G,'Layout','layered','EdgeLabel',eLabels);
G.Edges.LWidths = 1 + 2*[G.Edges.Weight-1];
p.LineWidth = G.Edges.LWidths;


xlabel('Thin edges: ineq. constraints. Thin self-edges: ..=0 constraints');