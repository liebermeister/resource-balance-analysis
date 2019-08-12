function rba_model_components_sbtab = rba_model_components_to_sbtab(rba_model_components)

my_Element.DOCUMENT_ATTRIBUTES = struct('DocumentType','rba-model-components');
elements = fieldnames(rba_model_components.elements);
for it =1:length(elements),
  my_Element.(elements{it}) = rba_model_components.elements.(elements{it});
  my_Element.(elements{it}).TABLE_ATTRIBUTES = struct('TableID',elements{it},'TableType','Quantity','TableGroup','elements');
end

variables = fieldnames(rba_model_components.variables);
for it =1:length(variables),
  my_Element.(variables{it}) = rba_model_components.variables.(variables{it});
  my_Element.(variables{it}).TABLE_ATTRIBUTES = struct('TableID',variables{it},'TableType','Quantity','TableGroup','variables');
end

rba_model_components_sbtab = struct_to_sbtab(my_Element);

table_names = fieldnames(rba_model_components.connections);
for it = 1:length(table_names),
  this_table = matrix_to_sbtab_table(rba_model_components.connections.(table_names{it}),table_names{it});
  rba_model_components_sbtab = sbtab_document_add_table(rba_model_components_sbtab,table_names{it},this_table);
end
