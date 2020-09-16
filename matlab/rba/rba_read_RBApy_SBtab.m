% -------------------------
% Example minimal CCM model
% -------------------------

file = '/home/wolfram/projekte/rba/rba-framework/rba-html/example_minimal_CCM/minimal_CCM/RBA_model.tsv';


% --------------------------------------------------------------------
% Load RBA SBtab data structure D
% --------------------------------------------------------------------

D_sbtab = sbtab_document_load_from_one(file);
%sbtab_print(D_sbtab)

% convert RBA SBtab into data strcuture 
D = sbtab_to_struct(D_sbtab,'column');


% --------------------------------------------------------------------
% Convert to data structure model-components (used in rba-symbolic)
% --------------------------------------------------------------------

% build 'model-components' data object R
R = struct;

% !! note: in RBApy, all elements are localised! 
% so this is actually NOT correct (but since the entities are not actually
% used, it will not lead to errors I guess ..)

R.Entity = struct;
R.Entity.Compartment      = struct;
R.Entity.Metabolite       = struct;
R.Entity.Reaction         = struct;
R.Entity.Enzyme           = struct;
R.Entity.Protein          = struct;
R.Entity.MolecularProcess = struct;
R.Entity.MolecularMachine = struct;   

R.Entity.Compartment.Name      = D.CellCompartment.ID; 
R.Entity.Metabolite.Name       = D.Metabolite.ID;      
R.Entity.Reaction.Name         = D.Reaction.ID;        
R.Entity.Enzyme.Name           = D.Enzyme.ID;          
R.Entity.Protein.Name          = D.Protein.ID;         
R.Entity.MolecularProcess.Name = D.Process.ID;         
R.Entity.MolecularMachine.Name = D.Process.ID;         
% note: in RBApy process and machine are not clearly distinguished!

% note: in RBApy, all elements are localised! so this is correct!
R.Element = struct;
R.Element.compartment                 = struct; 
R.Element.metabolite_compartment      = struct;
R.Element.reaction_enzyme_compartment = struct;
R.Element.enzyme_compartment          = struct;
R.Element.protein_compartment         = struct;
R.Element.process_compartment         = struct;
R.Element.machine_compartment         = struct;
R.Element.target                      = struct;

R.Element.compartment.IDsymbol                 = D.CellCompartment.ID; 
R.Element.metabolite_compartment.IDsymbol      = D.Metabolite.ID;
R.Element.reaction_enzyme_compartment.IDsymbol = D.Reaction.ID;
R.Element.enzyme_compartment.IDsymbol          = D.Enzyme.ID;
R.Element.protein_compartment.IDsymbol         = D.Protein.ID;
R.Element.process_compartment.IDsymbol         = D.Process.ID;
R.Element.machine_compartment.IDsymbol         = D.Process.ID;
R.Element.target.IDsymbol                      = D.CellTarget.ID;

n.compartment                 = length(R.Element.compartment.IDsymbol);
n.metabolite_compartment      = length(R.Element.metabolite_compartment.IDsymbol);      
n.reaction_enzyme_compartment = length(R.Element.reaction_enzyme_compartment.IDsymbol); 
n.enzyme_compartment          = length(R.Element.enzyme_compartment.IDsymbol);          
n.protein_compartment         = length(R.Element.protein_compartment.IDsymbol);         
n.process_compartment         = length(R.Element.process_compartment.IDsymbol);         
n.machine_compartment         = length(R.Element.machine_compartment.IDsymbol);         
n.target                      = length(R.Element.target.IDsymbol);                      

R.Variable = struct;
R.Variable.compartment_volume         = struct;
R.Variable.metabolite_rate            = struct;
R.Variable.metabolite_concentration   = struct;
R.Variable.metabolite_growth_balance  = struct;
R.Variable.reaction_flux              = struct;
R.Variable.reaction_flux_max_fw       = struct;
R.Variable.reaction_flux_max_bw       = struct;
R.Variable.enzyme_concentration       = struct;
R.Variable.protein_concentration      = struct;
R.Variable.protein_growth_balance     = struct;
R.Variable.process_flux               = struct;
R.Variable.process_flux_max           = struct;
R.Variable.machine_concentration      = struct;
R.Variable.compartment_packing        = struct;
R.Variable.compartment_packing_max    = struct;  

%% !! SETTING All lower bounds to 0 - FIX THIS!
R.Variable.compartment_volume.LowerBound         = repmat(0,n.compartment,1);
R.Variable.metabolite_rate.LowerBound            = repmat(0,n.metabolite_compartment,1);
R.Variable.metabolite_concentration.LowerBound   = repmat(0,n.metabolite_compartment,1);
R.Variable.metabolite_growth_balance.LowerBound  = repmat(0,n.metabolite_compartment,1);
R.Variable.reaction_flux.LowerBound              = repmat(0,n.reaction_enzyme_compartment,1);
R.Variable.reaction_flux_max_fw.LowerBound       = repmat(0,n.reaction_enzyme_compartment,1);
R.Variable.reaction_flux_max_bw.LowerBound       = repmat(0,n.reaction_enzyme_compartment,1);
R.Variable.enzyme_concentration.LowerBound       = repmat(0,n.enzyme_compartment,1);
R.Variable.protein_concentration.LowerBound      = repmat(0,n.protein_compartment,1);
R.Variable.protein_growth_balance.LowerBound     = repmat(0,n.protein_compartment,1);
R.Variable.process_flux.LowerBound               = repmat(0,n.process_compartment,1);
R.Variable.process_flux_max.LowerBound           = repmat(0,n.process_compartment,1);
R.Variable.machine_concentration.LowerBound      = repmat(0,n.machine_compartment,1);
R.Variable.compartment_packing.LowerBound        = repmat(0,n.compartment,1);
R.Variable.compartment_packing_max.LowerBound    = repmat(0,n.compartment,1);  

%% !! SETTING All upper bounds to infinity - FIX THIS!
R.Variable.compartment_volume.LowerBound         = repmat(inf,n.compartment,1);
R.Variable.metabolite_rate.LowerBound            = repmat(inf,n.metabolite_compartment,1);
R.Variable.metabolite_concentration.LowerBound   = repmat(inf,n.metabolite_compartment,1);
R.Variable.metabolite_growth_balance.LowerBound  = repmat(inf,n.metabolite_compartment,1);
R.Variable.reaction_flux.LowerBound              = repmat(inf,n.reaction_enzyme_compartment,1);
R.Variable.reaction_flux_max_fw.LowerBound       = repmat(inf,n.reaction_enzyme_compartment,1);
R.Variable.reaction_flux_max_bw.LowerBound       = repmat(inf,n.reaction_enzyme_compartment,1);
R.Variable.enzyme_concentration.LowerBound       = repmat(inf,n.enzyme_compartment,1);
R.Variable.protein_concentration.LowerBound      = repmat(inf,n.protein_compartment,1);
R.Variable.protein_growth_balance.LowerBound     = repmat(inf,n.protein_compartment,1);
R.Variable.process_flux.LowerBound               = repmat(inf,n.process_compartment,1);
R.Variable.process_flux_max.LowerBound           = repmat(inf,n.process_compartment,1);
R.Variable.machine_concentration.LowerBound      = repmat(inf,n.machine_compartment,1);
R.Variable.compartment_packing.LowerBound        = repmat(inf,n.compartment,1);
R.Variable.compartment_packing_max.LowerBound    = repmat(inf,n.compartment,1);  

reaction_formulae = strrep(D.Reaction.Formula,'''','');
nn = network_build_from_sum_formulae_list(reaction_formulae);

%FEHLENDE INFOS IN SBtab muessen noch ergänzt werden!!

%% !! R.Connection = struct;
%% !! R.Connection.growth_rate_Imet                   = []; 
%% !! R.Connection.growth_rate_Iprt                   = [];
R.Connection.N_reaction_stoichiometry           = nn.N;
%% !! R.Connection.N_metabolite_process_stoichiometry = [];
%% !! R.Connection.N_protein_process_stoichiometry    = [];
%% !! R.Connection.R_enzyme_composition               = [];
%% !! R.Connection.R_machine_composition              = [];
%% !! R.Connection.E_enzyme_capacity_fw               = [];
%% !! R.Connection.E_enzyme_capacity_bw               = [];
%% !! R.Connection.E_machine_capacity                 = [];
%% !! R.Connection.D_enzyme_volume                    = [];
%% !! R.Connection.D_machine_volume                   = [];
%% !! R.Connection.Q_compartment_crowding             = [];
%% !! R.Connection.L_target_process_flux              = [];  
