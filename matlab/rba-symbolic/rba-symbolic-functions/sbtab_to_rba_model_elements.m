function rba_model_elements = sbtab_to_rba_model_elements(rba_model_elements_sbtab)

rba_model_elements.TYPE = 'rba-model-network';
table_names = sbtab_document_get_table_names(rba_model_elements_sbtab);
for it = 1:length(table_names),
  this_table = sbtab_document_get_table(rba_model_elements_sbtab,table_names{it});
  attributes = sbtab_table_get_attributes(this_table);
  if isfield(attributes,'TableGroup'),
    switch attributes.TableGroup,
      case 'elements',
        rba_model_elements.elements.(table_names{it}).IDsymbol = sbtab_table_get_column(this_table,'IDsymbol');
      case 'variables',
        rba_model_elements.variables.(table_names{it}).LowerBound = sbtab_table_get_column(this_table,'LowerBound');
        rba_model_elements.variables.(table_names{it}).UpperBound = sbtab_table_get_column(this_table,'UpperBound');
    end
  else
    rba_model_elements.connections.(table_names{it}) = sbtab_table_to_matrix(this_table);
  end
end
