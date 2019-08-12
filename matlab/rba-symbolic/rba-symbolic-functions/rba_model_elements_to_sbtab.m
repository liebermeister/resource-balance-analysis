function rba_model_elements_sbtab = rba_model_elements_to_sbtab(rba_model_elements)

my_Element.DOCUMENT_ATTRIBUTES = struct('DocumentType','rba-model-elements');
elements = fieldnames(rba_model_elements.elements);
for it =1:length(elements),
  my_Element.(elements{it}) = rba_model_elements.elements.(elements{it});
  my_Element.(elements{it}).TABLE_ATTRIBUTES = struct('TableID',elements{it},'TableType','Quantity','TableGroup','elements');
end

variables = fieldnames(rba_model_elements.variables);
for it =1:length(variables),
  my_Element.(variables{it}) = rba_model_elements.variables.(variables{it});
  my_Element.(variables{it}).TABLE_ATTRIBUTES = struct('TableID',variables{it},'TableType','Quantity','TableGroup','variables');
end

rba_model_elements_sbtab = struct_to_sbtab(my_Element);

table_names = fieldnames(rba_model_elements.connections);
for it = 1:length(table_names),
  this_table = matrix_to_sbtab_table(rba_model_elements.connections.(table_names{it}),table_names{it});
  rba_model_elements_sbtab = sbtab_document_add_table(rba_model_elements_sbtab,table_names{it},this_table);
end
