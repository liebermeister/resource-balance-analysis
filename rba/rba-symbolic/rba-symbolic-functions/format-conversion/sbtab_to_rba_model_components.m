function rba_model_components = sbtab_to_rba_model_components(rba_model_components_sbtab)

% rba_model_components = sbtab_to_rba_model_components(rba_model_components_sbtab)
%
% Convert SBtab document (DocumentType 'rba-model-components') into 'rba-model-components' struct
% Inverse function of 'rba_model_components_to_sbtab'

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
      for it_type = 1:length(element_types_list)
        my_element_type = element_types_list{it_type};
        ind = find(strcmp(my_element_type,element_types));
        rba_model_components.Element.(my_element_type).ElementType = element_types(ind);
        rba_model_components.Element.(my_element_type).IDsymbol   = ID_symbols(ind);
      end
    case 'Quantity',
      quantity_types = sbtab_table_get_column(this_table,'QuantityType');
      quantity_types_list = unique(quantity_types);
      lower_bounds = sbtab_table_get_column(this_table,'LowerBound',1);
      upper_bounds = sbtab_table_get_column(this_table,'UpperBound',1);
      for it_type = 1:length(quantity_types_list)
        my_quantity_type = quantity_types_list{it_type};
        ind = find(strcmp(my_quantity_type,quantity_types));
        rba_model_components.Variable.(my_quantity_type).QuantityType = quantity_types(ind);
        rba_model_components.Variable.(my_quantity_type).LowerBound   = lower_bounds(ind);
        rba_model_components.Variable.(my_quantity_type).UpperBound   = upper_bounds(ind);
      end
    case 'Matrix',
      % (read columns directly: sbtab_table_to_matrix fails if the values were loaded as strings)
      columns = struct2cell(sbtab_table_get_all_columns(this_table));
      my_matrix = zeros(length(columns{1}), length(columns));
      for it_col = 1:length(columns)
        my_matrix(:,it_col) = cellfun(@(e) to_number(e), columns{it_col});
      end
      rba_model_components.Connection.(table_names{it}) = my_matrix;
    otherwise
      error(sprintf('Unknown table type %s in table %s', attributes.TableType, table_names{it}));
  end
end


% ------------------------------------------------

function v = to_number(e)

if ischar(e), v = str2double(e); else, v = double(e); end
