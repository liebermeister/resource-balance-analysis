function rba_model_components = sbtab_to_rba_model_components(rba_model_components_sbtab)

rba_model_components.DOCUMENT_ATTRIBUTES = rba_model_components_sbtab.attributes;
table_names = sbtab_document_get_table_names(rba_model_components_sbtab);
for it = 1:length(table_names),
  this_table = sbtab_document_get_table(rba_model_components_sbtab,table_names{it});
  attributes = sbtab_table_get_attributes(this_table);
  switch attributes.TableType,
    case 'Entity',
      rba_model_components.Entity.(attributes.TableID) = sbtab_to_struct(this_table,'column');
    case 'Element',
      element_types = sbtab_table_get_column(this_table,'ElementType');
      element_types_list = unique(element_types);
      ID_symbols = sbtab_table_get_column(this_table,'IDsymbol');
      for it =1:length(element_types_list),
        my_element_type = element_types_list{it};
        ind = label_names(my_element_type,element_types);
        rba_model_components.Element.(my_element_type).ElementType = element_types(ind);
        rba_model_components.Element.(my_element_type).IDsymbol   = ID_symbols(ind);
      end
    case 'Quantity',
      quantity_types = sbtab_table_get_column(this_table,'QuantityType');
      quantity_types_list = unique(quantity_types);
      lower_bounds = sbtab_table_get_column(this_table,'LowerBound');
      upper_bounds = sbtab_table_get_column(this_table,'UpperBound');
      for it =1:length(quantity_types_list),
        my_quantity_type = quantity_types_list{it};
        ind = label_names(my_quantity_type,quantity_types);
        rba_model_components.Variable.(my_quantity_type).QuantityType = quantity_types(ind);
        rba_model_components.Variable.(my_quantity_type).LowerBound   = lower_bounds(ind);
        rba_model_components.Variable.(my_quantity_type).UpperBound   = upper_bounds(ind);
      end
    case 'Matrix',
      rba_model_components.Connection.(table_names{it}) = sbtab_table_to_matrix(this_table);
    otherwise
      error('unknown table type');
  end
end
