function rba_model_components = rba_model_components_1_reaction()

% rba_model_components = rba_model_components_1_reaction()

rba_model_components = struct;

rba_model_components.DOCUMENT_ATTRIBUTES = struct('DocumentType', 'model-components', 'DocumentName', 'Model components: RBA model - 1 reaction');

rba_model_components.Entity.Compartment.Name      = numbered_names('cpt',1,0);
rba_model_components.Entity.Metabolite.Name       = numbered_names('met',1,0);
rba_model_components.Entity.Reaction.Name         = numbered_names('rea',1,0);
rba_model_components.Entity.Enzyme.Name           = numbered_names('enz',1,0);
rba_model_components.Entity.Protein.Name          = numbered_names('prt',2,0);
rba_model_components.Entity.MolecularProcess.Name = numbered_names('prc',1,0);
rba_model_components.Entity.MolecularMachine.Name = numbered_names('mch',1,0);
rba_model_components.Entity.Target.Name           = numbered_names('trg',1,0);

rba_model_components.Element.compartment.IDsymbol                  = numbered_names('cpt',1,0);
rba_model_components.Element.metabolite_compartment.IDsymbol       = numbered_names('met',1,0);
rba_model_components.Element.reaction_enzyme_compartment.IDsymbol  = numbered_names('rea',1,0);
rba_model_components.Element.enzyme_compartment.IDsymbol           = numbered_names('enz',1,0);
rba_model_components.Element.protein_compartment.IDsymbol          = numbered_names('prt',2,0);
rba_model_components.Element.process_compartment.IDsymbol          = numbered_names('prc',1,0);
rba_model_components.Element.machine_compartment.IDsymbol          = numbered_names('mch',1,0);
rba_model_components.Element.target.IDsymbol                       = numbered_names('trg',1,0);

rba_model_components.Variable.compartment_volume.LowerBound        = 0 * ones(1,1);
rba_model_components.Variable.metabolite_rate.LowerBound           = 0 * ones(1,1);
rba_model_components.Variable.metabolite_concentration.LowerBound  = 0 * ones(1,1);
rba_model_components.Variable.metabolite_growth_balance.LowerBound = 0 * ones(1,1);
rba_model_components.Variable.reaction_flux.LowerBound             = 0 * ones(1,1);
rba_model_components.Variable.reaction_flux_max_fw.LowerBound      = 0 * ones(1,1);
rba_model_components.Variable.reaction_flux_max_bw.LowerBound      = 0 * ones(1,1);
rba_model_components.Variable.enzyme_concentration.LowerBound      = 0 * ones(1,1);
rba_model_components.Variable.protein_concentration.LowerBound     = 0 * ones(2,1);
rba_model_components.Variable.protein_growth_balance.LowerBound    = 0 * ones(2,1);
rba_model_components.Variable.process_flux.LowerBound              = 0 * ones(1,1);
rba_model_components.Variable.process_flux_max.LowerBound          = 0 * ones(1,1);
rba_model_components.Variable.machine_concentration.LowerBound     = 0 * ones(1,1);
rba_model_components.Variable.compartment_packing.LowerBound       = 0 * ones(1,1);
rba_model_components.Variable.compartment_packing_max.LowerBound   = 0 * ones(1,1);

rba_model_components.Variable.compartment_volume.UpperBound        = 1 * ones(1,1);
rba_model_components.Variable.metabolite_rate.UpperBound           = 1 * ones(1,1);
rba_model_components.Variable.metabolite_concentration.UpperBound  = 1 * ones(1,1);
rba_model_components.Variable.metabolite_growth_balance.UpperBound = 1 * ones(1,1);
rba_model_components.Variable.reaction_flux.UpperBound             = 1 * ones(1,1);
rba_model_components.Variable.reaction_flux_max_fw.UpperBound      = 1 * ones(1,1);
rba_model_components.Variable.reaction_flux_max_bw.UpperBound      = 1 * ones(1,1);
rba_model_components.Variable.enzyme_concentration.UpperBound      = 1 * ones(1,1);
rba_model_components.Variable.protein_concentration.UpperBound     = 1 * ones(2,1);
rba_model_components.Variable.protein_growth_balance.UpperBound    = 1 * ones(2,1);
rba_model_components.Variable.process_flux.UpperBound              = 1 * ones(1,1);
rba_model_components.Variable.process_flux_max.UpperBound          = 1 * ones(1,1);
rba_model_components.Variable.machine_concentration.UpperBound     = 1 * ones(1,1);
rba_model_components.Variable.compartment_packing.UpperBound       = 1 * ones(1,1);
rba_model_components.Variable.compartment_packing_max.UpperBound   = 1 * ones(1,1);

rba_model_components.Connection.growth_rate_Imet                   = eye(1);
rba_model_components.Connection.growth_rate_Iprt                   = eye(2);
rba_model_components.Connection.N_reaction_stoichiometry           = [1];
rba_model_components.Connection.N_metabolite_process_stoichiometry = [-1];
rba_model_components.Connection.N_protein_process_stoichiometry    = [1; 1];
rba_model_components.Connection.R_enzyme_composition               = [1; 0];
rba_model_components.Connection.R_machine_composition              = [0; 1];
rba_model_components.Connection.E_enzyme_capacity_fw               = [1];
rba_model_components.Connection.E_enzyme_capacity_bw               = [1];
rba_model_components.Connection.E_machine_capacity                 = [1];
rba_model_components.Connection.D_enzyme_volume                    = [1];
rba_model_components.Connection.D_machine_volume                   = [1];
rba_model_components.Connection.Q_compartment_crowding             = [1];
rba_model_components.Connection.L_target_process_flux              = [1];
