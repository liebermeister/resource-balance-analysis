% ------------------------------------------------------------------
% Resource balance analysis - model construction based on symbolic representation
% For a description of data structures used, see 'help rba-symbolic'
% ------------------------------------------------------------------


% ----------------------------------------------------
% 1. Read model schematic (from "model-schematic.tsv" file)
% ----------------------------------------------------

%rba_model_scheme_file  = [rba_basedir '/resources/model-schematic/rba-model-schematic.tsv'];
rba_model_scheme_file  = [rba_basedir '/resources/model-schematic//scott_mass_balance_model-schematic.tsv'];

rba_model_scheme_sbtab = sbtab_document_load(rba_model_scheme_file);
rba_model_scheme       = sbtab_to_struct(rba_model_scheme_sbtab,'row');

% check: show model scheme
% sbtab_print(rba_model_scheme_sbtab,'all')

% check: convert back to sbtab object
% sbtab_print(struct_to_sbtab(rba_model_scheme),'all');


% ----------------------------------------------------------------------------------
% 2. Read cell information ("model components": IDs, bounds, connection matrices)
% ----------------------------------------------------------------------------------

%rba_model_components = rba_model_components_simple_example;
rba_model_components = rba_model_components_scott_mass_balance;

% check: convert to sbtab object (of document type "rba-model-elements")
% sbtab_print(rba_model_components_to_sbtab(rba_model_components),'all')

% check: save and load data objects
% sbtab_document_save(rba_model_components_to_sbtab(rba_model_components),'/home/wolfram/projekte/rba/rba-theory/rba-symbolic/examples/results/test_model-network.tsv')
% sbtab_print(sbtab_document_load('/home/wolfram/projekte/rba/rba-theory/rba-symbolic/examples/test_model-network.tsv'),'all');
% check: convert back to rba_model_components object
% dum = sbtab_to_rba_model_components(rba_model_components_sbtab)


% -------------------------------------------------------------
% 3. Generate rba-model structure and LP problem (symbolic form)
% -------------------------------------------------------------

[rba_model, rba_model_components] = rba_make_model(rba_model_scheme, rba_model_components);

rba_problem_symbolic = rba_make_linear_problem_symbolic(rba_model, rba_model_components);


% -------------------------------------------------------------
% 4. Generate LP optimality problem (numeric form)
% -------------------------------------------------------------

rba_problem_numeric = rba_make_linear_problem_numeric(rba_problem_symbolic, rba_model, rba_model_components);


% -------------------------------------------------------------
% 5. Generate LP optimality problem (numeric form)
% -------------------------------------------------------------

[x_opt, f_opt, w_opt] = rba_linear_problem_solve(rba_problem_numeric,'vmet_rea_1');


% -------------------------------------------------------------
% 6. Display LP optimality problem and results
% -------------------------------------------------------------

rba_linear_problem_symbolic_display(rba_problem_symbolic,'equations');

rba_linear_problem_numeric_display(rba_problem_numeric);

rba_linear_problem_solution_display(rba_problem_numeric, x_opt, f_opt, w_opt)

