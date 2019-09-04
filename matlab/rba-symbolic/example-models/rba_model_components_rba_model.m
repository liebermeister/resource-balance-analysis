function rba_model_components = rba_model_components_simple_example()

% rba_model_components = rba_model_components_simple_example()

rba_model_components = struct;

% rba_model_components.entities.Compartment.Name      = numbered_names('cpt ',1,0);
% rba_model_components.entities.Metabolite.Name       = numbered_names('met ',1,0);
% rba_model_components.entities.Reaction.Name         = numbered_names('rea ',1,0);
% rba_model_components.entities.Enzyme.Name           = numbered_names('enz ',1,0);
% rba_model_components.entities.Protein.Name          = numbered_names('prt ',2,0);
% rba_model_components.entities.MolecularProcess.Name = numbered_names('prc ',1,0);
% rba_model_components.entities.MolecularProcess.Name = numbered_names('mch ',1,0);
% rba_model_components.entities.CustomVariable.Name   = numbered_names('tgt ',1,0);

rba_model_components.elements.compartment.IDsymbol                  = numbered_names('cpt',1,0);
rba_model_components.elements.metabolite_compartment.IDsymbol       = numbered_names('met',1,0);
rba_model_components.elements.reaction_enzyme_compartment.IDsymbol  = numbered_names('rea',1,0);
rba_model_components.elements.enzyme_compartment.IDsymbol           = numbered_names('enz',1,0);
rba_model_components.elements.protein_compartment.IDsymbol          = numbered_names('prt',2,0);
rba_model_components.elements.process_compartment.IDsymbol          = numbered_names('prc',1,0);
rba_model_components.elements.machine_compartment.IDsymbol          = numbered_names('mch',1,0);
rba_model_components.elements.customvariable.IDsymbol                       = numbered_names('tgt',1,0);

% rba_model_components.variables.compartment_volume.LowerBound        = 0 * ones(1,1);
% rba_model_components.variables.metabolite_concentration.LowerBound  = 0 * ones(1,1);
% rba_model_components.variables.metabolite_growth_balance.LowerBound = 0 * ones(1,1);
% rba_model_components.variables.reaction_flux.LowerBound             = 0 * ones(1,1);
% rba_model_components.variables.reaction_flux_max_fw.LowerBound      = 0 * ones(1,1);
% rba_model_components.variables.reaction_flux_max_bw.LowerBound      = 0 * ones(1,1);
% rba_model_components.variables.enzyme_concentration.LowerBound      = 0 * ones(1,1);
% rba_model_components.variables.protein_concentration.LowerBound     = 0 * ones(2,1);
% rba_model_components.variables.protein_growth_balance.LowerBound    = 0 * ones(2,1);
% rba_model_components.variables.process_flux.LowerBound              = 0 * ones(1,1);
% rba_model_components.variables.process_flux_max.LowerBound          = 0 * ones(1,1);
% rba_model_components.variables.machine_concentration.LowerBound     = 0 * ones(1,1);
% rba_model_components.variables.compartment_packing.LowerBound       = 0 * ones(1,1);
% rba_model_components.variables.compartment_packing_max.LowerBound   = 0 * ones(1,1);
% rba_model_components.variables.customvariable.LowerBound              = 0 * ones(1,1);

% rba_model_components.variables.compartment_volume.UpperBound        = 1 * ones(1,1);
% rba_model_components.variables.metabolite_concentration.UpperBound  = 1 * ones(1,1);
% rba_model_components.variables.metabolite_growth_balance.UpperBound = 1 * ones(1,1);
% rba_model_components.variables.reaction_flux.UpperBound             = 1 * ones(1,1);
% rba_model_components.variables.reaction_flux_max_fw.UpperBound      = 1 * ones(1,1);
% rba_model_components.variables.reaction_flux_max_bw.UpperBound      = 1 * ones(1,1);
% rba_model_components.variables.enzyme_concentration.UpperBound      = 1 * ones(1,1);
% rba_model_components.variables.protein_concentration.UpperBound     = 1 * ones(2,1);
% rba_model_components.variables.protein_growth_balance.UpperBound    = 1 * ones(2,1);
% rba_model_components.variables.process_flux.UpperBound              = 1 * ones(1,1);
% rba_model_components.variables.process_flux_max.UpperBound          = 1 * ones(1,1);
% rba_model_components.variables.machine_concentration.UpperBound     = 1 * ones(1,1);
% rba_model_components.variables.compartment_packing.UpperBound       = 1 * ones(1,1);
% rba_model_components.variables.compartment_packing_max.UpperBound   = 1 * ones(1,1);
% rba_model_components.variables.customvariable.UpperBound              = 1 * ones(1,1);

rba_model_components.connections.growth_rate_Imet                    = eye(1);
rba_model_components.connections.growth_rate_Iprt                    = eye(2);
rba_model_components.connections.N_reaction_stoichiometry            = [1];
rba_model_components.connections.N_metabolite_process_stoichiometry  = [-1];
rba_model_components.connections.N_protein_process_stoichiometry     = [1; 1];
rba_model_components.connections.R_enzyme_composition                = [1; 0];
rba_model_components.connections.R_machine_composition               = [0; 1];
rba_model_components.connections.E_enzyme_capacity_fw                = [1];
rba_model_components.connections.E_enzyme_capacity_bw                = [1];
rba_model_components.connections.E_machine_capacity                  = [1];
rba_model_components.connections.D_enzyme_volume                     = [1];
rba_model_components.connections.D_machine_volume                    = [1];
rba_model_components.connections.L_customvariable_metabolite         = [0];
rba_model_components.connections.L_customvariable_reaction_flux      = [1];
rba_model_components.connections.L_customvariable_process_flux       = [0];
rba_model_components.connections.L_customvariable_protein            = [0 0];
rba_model_components.connections.L_customvariable_machine            = [0];
rba_model_components.connections.Q_compartment_crowding              = [1];
