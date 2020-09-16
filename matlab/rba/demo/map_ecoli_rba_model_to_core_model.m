% ----------------------------------------------------------------------------
% Load RBA results for large E coli model

infile    = '/home/wolfram/Desktop/tmp/rba_output_sbtab.tsv';
D         = sbtab_document_load_from_one(infile);
enzyme    = sbtab_table_convert_to_struct(sbtab_document_get_table(D,'Enzyme'));
reaction  = sbtab_table_convert_to_struct(sbtab_document_get_table(D,'Reaction'));
machinery = sbtab_table_convert_to_struct(sbtab_document_get_table(D,'Machinery'));


% ----------------------------------------------------------------------------
% Load E coli core model (for more adjustments, see matlab code in glass ceiling directory)

ecoli_core_sbml   = '/home/wolfram/arbeit/modelle/bigg_models/bigg_e_coli_core/e_coli_core.xml';
ecoli_core_layout = '/home/wolfram/projekte/glass_ceiling/matlab/model_bigg_e_coli_core/e_coli_core_Layout.tsv';

network = network_sbml_import(ecoli_core_sbml);
network = network_remove_action(network,label_names('R_BIOMASS_Ecoli_core_w_GAM',network.actions));
network = network_remove(network,label_names({'M_h2o_c','M_h2o_e'},network.metabolites));
network = network_remove_action(network,label_names({'R_FBP','R_EX_h2o_e','R_H2Ot','R_FORt'},network.actions));
network = netgraph_read_positions(network,ecoli_core_layout);
network.graphics_par.squaresize=0.015;

% ----------------------------------------------------------------------------
% Map RBA fluxes and enzyme levels onto core model

reaction.Reaction_name = rba_simplify_reaction_names(reaction.Reaction);
v  = nan*ones(size(network.actions));
ll = label_names(network.actions,reaction.Reaction_name);
v(find(ll)) = cell_string2num(reaction.Value(ll(find(ll))));

enzyme.Reaction_name = rba_simplify_reaction_names(enzyme.Reaction);
u  = nan*ones(size(network.actions));
ll = label_names(network.actions,enzyme.Reaction_name);
u(find(ll)) = cell_string2num(enzyme.Value(ll(find(ll))));

% Problems 
% rba_simplify_reaction_names fixes only up to 6 isoenzymes
% there is still "_copy1" and "_copy2" in some reaction names
% fluxes still look weird

% ----------------------------------------------------------------------------
% Display RBA fluxes and enzyme levels on core model

figure(1); netgraph_fluxes(network,v,struct('arrowcolor',[1 0 0]));
figure(2); netgraph_concentrations(network,[],u,1);

return

% ----------------------------------------------------------------------------
% Load iJO1366 E coli model

[network_ecoli_iJO1366, ecoli_iJO1366_ind_biomass_reaction]  = ecoli_iJO1366_make_model;

% The RBA version of iJO1366 has 3901 reactions; after collapsing isoenzymes, there remain 2577 reactions
% The iJO1366 model (both from Dan and from BIGG?) contains 2583 reactions, all with distinct names
% There are quite a few differences in both directions (which, in addition, depend on whether Dan's version or the BIGG website version of the model is used ..) 

if 0,
  unique(setdiff(network_ecoli_iJO1366.actions, reaction.Reaction_name))
  unique(setdiff(reaction.Reaction_name,network_ecoli_iJO1366.actions))
end

