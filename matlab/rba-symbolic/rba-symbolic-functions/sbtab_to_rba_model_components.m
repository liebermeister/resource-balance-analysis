function rba_model_components = sbtab_to_rba_model_components(rba_model_components_sbtab)

rba_model_components.TYPE = 'rba-model-network';
table_names = sbtab_document_get_table_names(rba_model_components_sbtab);
for it = 1:length(table_names),
  this_table = sbtab_document_get_table(rba_model_components_sbtab,table_names{it});
  attributes = sbtab_table_get_attributes(this_table);
  if isfield(attributes,'TableGroup'),
    switch attributes.TableGroup,
      case 'elements',
        rba_model_components.elements.(table_names{it}).IDsymbol = sbtab_table_get_column(this_table,'IDsymbol');
      case 'variables',
        rba_model_components.variables.(table_names{it}).LowerBound = sbtab_table_get_column(this_table,'LowerBound');
        rba_model_components.variables.(table_names{it}).UpperBound = sbtab_table_get_column(this_table,'UpperBound');
    end
  else
    rba_model_components.connections.(table_names{it}) = sbtab_table_to_matrix(this_table);
  end
end
