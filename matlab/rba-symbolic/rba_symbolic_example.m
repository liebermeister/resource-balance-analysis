% ----------------------------------------------------
% Read model schematic from "model-schematic.tsv" file
% ----------------------------------------------------

% for data structure 'rba_model_scheme', see 'help rba-symbolic'
%rba_model_scheme_file  = [rba_basedir '/resources/model-schematic/rba-model-schematic.tsv'];
rba_model_scheme_file  = [rba_basedir '/resources/model-schematic//scott_mass_balance_model-schematic.tsv'];

rba_model_scheme_sbtab = sbtab_document_load(rba_model_scheme_file);
rba_model_scheme       = sbtab_to_struct(rba_model_scheme_sbtab,'row');

% test: show model scheme
% sbtab_print(rba_model_scheme_sbtab,'all')

% test: convert back to sbtab object
% sbtab_print(struct_to_sbtab(rba_model_scheme),'all');


% ----------------------------------------------------------------------------------
% Read cell information for a small example model (IDs, bounds, connection matrices)
% ----------------------------------------------------------------------------------

%rba_model_components = rba_model_components_simple_example;
rba_model_components = rba_model_components_scott_mass_balance;

% test: convert to sbtab object (of document type "rba-model-elements")
% sbtab_print(rba_model_components_to_sbtab(rba_model_components),'all')

% sbtab_document_save(rba_model_components_to_sbtab(rba_model_components),'/home/wolfram/projekte/rba/rba-theory/rba-symbolic/examples/results/test_model-network.tsv')
% sbtab_print(sbtab_document_load('/home/wolfram/projekte/rba/rba-theory/rba-symbolic/examples/test_model-network.tsv'),'all');
% convert back to rba_model_components object
% dum = sbtab_to_rba_model_components(rba_model_components_sbtab)


% -------------------------------------------------------------
% Generate rba-model structure and LP problem, solve LP problem
% -------------------------------------------------------------

[rba_model, rba_model_components] = rba_make_model(rba_model_scheme, rba_model_components);

rba_problem_symbolic = rba_make_linear_problem_symbolic(rba_model, rba_model_components);

rba_problem_numeric = rba_make_linear_problem_numeric(rba_problem_symbolic, rba_model, rba_model_components);

[x_opt, f_opt, w_opt] = rba_linear_problem_solve(rba_problem_numeric,'vmet_rea_1');


% -------------------------------------------------------------
% Display LP problem and optimisation results
% -------------------------------------------------------------

rba_linear_problem_symbolic_display(rba_problem_symbolic,'equations');

rba_linear_problem_numeric_display(rba_problem_numeric);

rba_linear_problem_solution_display(rba_problem_numeric, x_opt, f_opt, w_opt)

