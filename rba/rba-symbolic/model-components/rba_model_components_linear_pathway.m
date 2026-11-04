function rba_model_components = rba_model_components_linear_pathway(kcat)

% rba_model_components = rba_model_components_linear_pathway(kcat)
%
% Enzyme-constrained linear pathway  -> A -> B ->  (uptake, conversion, export)
% with three enzymes (forward kcat values given by vector kcat, default [1; 2; 4]),
% irreversible reactions, and one compartment with enzyme volume capacity 1.
%
% The maximal pathway flux is v_max = 1 / sum(1 ./ kcat)
%
% Matching model schema: metabolic_steady_state

eval(default('kcat','[1; 2; 4]'));

rba_model_components = struct;

rba_model_components.DOCUMENT_ATTRIBUTES = struct('DocumentType', 'rba-model-components', 'DocumentName', 'Model components: linear pathway with three enzymes');

rba_model_components.Entity.Compartment.Name = {'cytosol'};
rba_model_components.Entity.Metabolite.Name  = {'A'; 'B'};
rba_model_components.Entity.Reaction.Name    = {'uptake'; 'conversion'; 'export'};
rba_model_components.Entity.Enzyme.Name      = {'E_uptake'; 'E_conversion'; 'E_export'};

rba_model_components.Element.compartment.IDsymbol                 = {'cyt'};
rba_model_components.Element.metabolite_compartment.IDsymbol      = {'A_cyt'; 'B_cyt'};
rba_model_components.Element.reaction_enzyme_compartment.IDsymbol = {'R1'; 'R2'; 'R3'};
rba_model_components.Element.enzyme_compartment.IDsymbol          = {'E1'; 'E2'; 'E3'};

rba_model_components.Variable.compartment_volume.LowerBound = 1;
rba_model_components.Variable.compartment_volume.UpperBound = 1;

rba_model_components.Parameter.enzyme_capacity_fw.Value          = kcat(:);
rba_model_components.Parameter.enzyme_capacity_bw.Value          = [0; 0; 0];   % irreversible reactions
rba_model_components.Parameter.enzyme_volume.Value               = [1; 1; 1];
rba_model_components.Parameter.compartment_volume_capacity.Value = 1;

% E_enzyme_capacity_fw/bw (= diag(kcat)) and Q_compartment_crowding are computed from the parameters;
% the matrices below cannot be diagonal and must be given explicitly

rba_model_components.Connection.N_reaction_stoichiometry = [1 -1  0; ...
                                                            0  1 -1];
rba_model_components.Connection.D_enzyme_volume          = [1 1 1];
