function rba_model_components_sbtab = rba_model_components_to_sbtab(rba_model_components)

my_struct.DOCUMENT_ATTRIBUTES = struct('DocumentType','rba-model-components');

entities = fieldnames(rba_model_components.Entity);
for it =1:length(entities),
  my_struct.(entities{it}) = rba_model_components.Entity.(entities{it});
  my_struct.(entities{it}).TABLE_ATTRIBUTES = struct('TableID',entities{it},'TableType','Entity');
end

rba_model_components_sbtab = struct_to_sbtab(my_struct);

% ------------------------
% add table with elements

elements_table_sbtab = sbtab_table_construct(struct('TableID','Element','TableType','Element'), ...
                                             {'IDsymbol','ElementType'},{[],[]});
 elements = fieldnames(rba_model_components.Element);
 for it =1:length(elements),
   n = length(rba_model_components.Element.(elements{it}).IDsymbol);
   rba_model_components.Element.(elements{it}).ElementType = repmat({elements{it}},n,1);
   my_table = struct_to_sbtab(rba_model_components.Element.(elements{it}),'table');
   elements_table_sbtab = sbtab_table_combine_vertically(elements_table_sbtab, my_table);
 end

rba_model_components_sbtab = sbtab_document_add_table(rba_model_components_sbtab,'Element',elements_table_sbtab);

% ------------------------
% add table with variables

variables_table_sbtab = sbtab_table_construct(struct('TableID','Variable','TableType','Quantity'), ...
                                             {'LowerBound','UpperBound','QuantityType'},{[],[],[]});
 variables = fieldnames(rba_model_components.Variable);
 for it =1:length(variables),
   n = length(rba_model_components.Variable.(variables{it}).LowerBound);
   rba_model_components.Variable.(variables{it}).QuantityType = repmat({variables{it}},n,1);
   my_table = struct_to_sbtab(rba_model_components.Variable.(variables{it}),'table');
   variables_table_sbtab = sbtab_table_combine_vertically(variables_table_sbtab, my_table);
 end

rba_model_components_sbtab = sbtab_document_add_table(rba_model_components_sbtab,'Variable',variables_table_sbtab);

% ---------------------------
% add tables with connections

table_names = fieldnames(rba_model_components.Connection);
for it = 1:length(table_names),
  this_table = matrix_to_sbtab_table(rba_model_components.Connection.(table_names{it}),table_names{it});
  rba_model_components_sbtab = sbtab_document_add_table(rba_model_components_sbtab,table_names{it},this_table);
end
