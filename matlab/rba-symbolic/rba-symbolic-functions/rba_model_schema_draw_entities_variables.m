function rba_model_schema_draw_entities_variables(rba_model_schema)

entity   = setdiff(fieldnames(rba_model_schema.EntityType),{'TABLE_ATTRIBUTES'});
element  = setdiff(fieldnames(rba_model_schema.ElementType),{'TABLE_ATTRIBUTES'});
variable = setdiff(fieldnames(rba_model_schema.VariableType),{'TABLE_ATTRIBUTES'});

n_entity = length(entity);
n_element = length(element);
n_variable = length(variable);

A = sparse(zeros(n_entity+n_element+n_variable));

for it=1:length(element),
  my_element = rba_model_schema.ElementType.(element{it});
  dum = jsondecode(my_element.Definition);
  fn = fieldnames(dum);
  for it2 = 1:length(fn),
    my_entity = dum.(fn{it2});
    ind_entity = find(strcmp(my_entity,entity));
    if length(ind_entity) == 0,
      my_element
      error('ElementType refers to unknown entity type');
    end
    A(ind_entity,n_entity +it) = 1;
  end
end

for it=1:length(variable),
  my_variable = rba_model_schema.VariableType.(variable{it});
  ind_element = find(strcmp(my_variable.indexed_by,element));
  if length(ind_element) == 0,
    my_variable
    error('VariableType refers to unknown element type');
  end
  A(n_entity+ind_element,n_entity+n_element +it) = 2;
end


G = digraph(A,strrep([entity; element; variable],'_',' '));
p = plot(G,'Layout','layered');
G.Edges.LWidths = 1 + 2*[G.Edges.Weight-1];
p.LineWidth = G.Edges.LWidths;

xlabel('Layers show (1) Entities (2) Elements (3) Variables');