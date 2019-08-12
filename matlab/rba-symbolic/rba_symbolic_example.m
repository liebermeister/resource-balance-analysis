% ---------------------------------------------------
% read model scheme from file rba-model-schematic.tsv
% ---------------------------------------------------

%rba_model_scheme_file  = '/home/wolfram/projekte/rba/rba-theory/rba-symbolic/example/rba-model-schematic.tsv';
rba_model_scheme_file  = '/home/wolfram/projekte/rba/rba-theory/rba-symbolic/example/scott_mass_balance_model-schematic.tsv';
rba_model_scheme_sbtab = sbtab_document_load(rba_model_scheme_file);
rba_model_scheme       = sbtab_to_struct(rba_model_scheme_sbtab,'row');

% sbtab_print(rba_model_scheme_sbtab,'all')

% test: convert back to sbtab object
% sbtab_print(struct_to_sbtab(rba_model_scheme),'all');


% -------------------------------------------------------
% read cell information for a small example model 
% (IDs, bounds, connection matrices)
% -------------------------------------------------------

%rba_model_components = rba_define_simple_example_model;
rba_model_components = rba_define_scott_mass_balance_model;

% test: convert to sbtab object (of document type "rba-model-elements")
% rba_model_components_sbtab = rba_model_components_to_sbtab(rba_model_components);
% sbtab_print(rba_model_components_sbtab,'all')

% sbtab_document_save(rba_model_components_sbtab,'/home/wolfram/projekte/rba/rba-theory/rba-symbolic/examples/results/test_model-network.tsv')
% sbtab_print(sbtab_document_load('/home/wolfram/projekte/rba/rba-theory/rba-symbolic/examples/test_model-network.tsv'),'all');
% convert back to rba_model_components object
% dum = sbtab_to_rba_model_components(rba_model_components_sbtab)

% -------------------------------------------------------
% generate rba-model structure
% (includes LP problem in symbolic and numeric form)
% -------------------------------------------------------

[rba_model, rba_model_components] = rba_model_construct(rba_model_scheme, rba_model_components);

rba_problem = rba_model_to_linear_problem(rba_model, rba_model_components);

rba_linear_problem_symbolic_display(rba_problem.symbolic,'equations');

% rba_linear_problem_numeric_display(rba_problem.numeric);

[x_opt, f_opt, w_opt] = rba_linear_problem_solve(rba_problem.numeric,'vmet_rea_1');

pm(x_opt,rba_problem.numeric.x_id)
pm(w_opt.eqlin,rba_problem.numeric.a_eq_id)
pm(w_opt.ineqlin,rba_problem.numeric.b_in_id)
pm(w_opt.lower,rba_problem.numeric.x_id)
pm(w_opt.upper,rba_problem.numeric.x_id)

