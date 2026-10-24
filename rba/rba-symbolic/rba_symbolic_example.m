% ------------------------------------------------------------------
% Resource balance analysis - model construction based on symbolic representation
% For a description of data structures used, see 'help rba-symbolic'
% ------------------------------------------------------------------


% ----------------------------------------------------
% 1. Load model schema (from "model-schema.tsv" file)
% ----------------------------------------------------

%rba_model_schema_file  = [rba_basedir '/resources/rba-model-schema-files/rba_steady_growth_model-schema.tsv'];
%rba_model_schema_file  = [rba_basedir '/resources/rba-model-schema-files/metabolic_growth_state_model-schema.tsv'];
rba_model_schema_file  = [rba_basedir '/resources/rba-model-schema-files/metabolic_steady_state_model-schema.tsv'];

rba_model_schema_sbtab = sbtab_document_load(rba_model_schema_file);
rba_model_schema       = sbtab_to_struct(rba_model_schema_sbtab,'row');

% original sbtab object:
% sbtab_print(rba_model_schema_sbtab,'all')

% sbtab object after roundtrip
% sbtab_print(struct_to_sbtab(rba_model_schema),'all');

figure(1); rba_model_schema_draw_entities_variables(rba_model_schema)
figure(2); rba_model_schema_draw_dependencies(rba_model_schema);

%!!!statt selbstkante (für =0) lieber den knoten anmalen?

% ----------------------------------------------------------------------------------
% 2. Load cell information ("model components": IDs, bounds, connection matrices)
% ----------------------------------------------------------------------------------

% In the current examples, the rba_model_components structures are not read from SBtab files,
% directly generated my matlab functions

rba_model_components = rba_model_components_1_reaction;

% show as json string: 
% rba_model_components_json = jsonencode(rba_model_components) 

% convert to sbtab:
% rba_model_components_sbtab = rba_model_components_to_sbtab(rba_model_components);
% sbtab_print(rba_model_components_sbtab,'all')

% check round trip: 
% convert back to rba_model_components object
% sbtab_to_rba_model_components(rba_model_components_sbtab)

% save, load, show, and convert back (roundtrip)
% filename = '/home/wolfram/projekte/rba/rba-theory/rba-symbolic/examples/results/test_model-network.tsv';
% sbtab_document_save(rba_model_components_sbtab,filename)
% sbtab_print(sbtab_document_load(filename),'all');
% sbtab_to_rba_model_components(sbtab_document_load(filename))


% -------------------------------------------------------------
% 3. Generate rba-model structure and LP problem (symbolic form)
% -------------------------------------------------------------

rba_model_indices = rba_make_model_indices(rba_model_schema, rba_model_components);

rba_problem_symbolic = rba_make_linear_problem_symbolic(rba_model_indices, rba_model_components);


% -------------------------------------------------------------
% 4. Generate LP optimality problem (numerical form)
% -------------------------------------------------------------

rba_problem_numerical = rba_make_linear_problem_numerical(rba_problem_symbolic, rba_model_indices, rba_model_components);

% SHOW AS JSON STRING: rba_model_components_json = jsonencode(rba_problem_compact) 

% -------------------------------------------------------------
% 5. Generate LP optimality problem (numerical form)
% -------------------------------------------------------------

[x_opt, f_opt, w_opt] = rba_linear_problem_solve(rba_problem_numerical,'vmet_rea_1');


% -------------------------------------------------------------
% 6. Display LP optimality problem and results
% -------------------------------------------------------------

rba_linear_problem_symbolic_display(rba_problem_symbolic,'equations');

rba_linear_problem_numerical_display(rba_problem_numerical);

rba_linear_problem_solution_display(rba_problem_numerical, x_opt, f_opt, w_opt)


% -------------------------------------------------------------
% 7. Convert to RBA data format and run RBA 
% -------------------------------------------------------------

% run rba (so far, LP seems to work; growth maximisation is implemented, but needs to be tested!)
% also the growth maximisation RBA requires, so far, matrices split into A_1 + p * A_p, which still needs to be implemented
% here on the symbolic RBA side

% Oliver's compact LP format (similar to cobra format):
rba_problem_compact = lp_problem_numerical_to_lp_problem_compact(rba_problem_numerical);
%also: rba_problem         = lp_problem_compact_to_lp_problem(lp_problem);

% My standard LP format 
rba_problem  = lp_problem_numerical_to_lp_problem(rba_problem_numerical);

[~,solution] = rba(rba_problem,struct('method', 'LP_problem')); 
