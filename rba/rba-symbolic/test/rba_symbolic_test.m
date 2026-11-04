function rba_symbolic_test()

% rba_symbolic_test()
%
% Regression tests for symbolic RBA model construction (run from any directory):
%  1. all model schema files pass rba_model_schema_check
%  2. linear pathway (schema metabolic_steady_state): maximal flux = 1 / sum(1/kcat)
%  3. minimal RBA model (schemas rba_steady_growth and metabolic_growth_state):
%     maximal reaction flux at growth rate 1 is 0.5
%  4. maximal growth rate (rba.m, method 'maximise_growth') of the minimal RBA model is 1
%  5. SBtab round trip of model components
%  6. conversion between LP data formats

schema_dir = [rba_basedir '/resources/rba-model-schema-files/'];
tol = 10^-6;
n_failed = 0;

% 1. schema files

files = {'metabolic_steady_state', 'metabolic_growth_state', 'rba_steady_growth'};
for it = 1:length(files)
  schema.(files{it}) = sbtab_to_struct(sbtab_document_load([schema_dir files{it} '_model-schema.tsv']),'row');
  problems = rba_model_schema_check(schema.(files{it}), 0);
  n_failed = n_failed + report(isempty(problems), ['schema check ' files{it}], strjoin(problems, '; '));
end

% 2. linear pathway

kcat = [1; 2; 4];
[x, f] = build_and_solve(schema.metabolic_steady_state, rba_model_components_linear_pathway(kcat), 'vmet_R2');
n_failed = n_failed + report(abs(f - 1/sum(1./kcat)) < tol, 'linear pathway: maximal flux', sprintf('got %g, expected %g', f, 1/sum(1./kcat)));

% 3. minimal RBA model

for name = {'rba_steady_growth', 'metabolic_growth_state'}
  [x, f] = build_and_solve(schema.(name{1}), rba_model_components_1_reaction, 'vmet_rea_1');
  n_failed = n_failed + report(abs(f - 0.5) < tol, ['minimal RBA model, ' name{1} ': maximal flux'], sprintf('got %g, expected 0.5', f));
end

% 4. growth rate maximisation (target: process flux >= 0.1; problem infeasible for mu < 0.2)

components = rba_model_components_1_reaction;
components.Variable.target_value.LowerBound = 0.1;
components.Variable.target_value.UpperBound = inf;
rba_problem = rba_make_linear_problem_parameterised(schema.rba_steady_growth, components, 'growth_rate');
[~, solution] = rba(rba_problem, struct('method', 'maximise_growth', 'parameter_min', 0.25, 'parameter', 0.5));
n_failed = n_failed + report(abs(solution.Objective - 1) < tol, 'minimal RBA model: maximal growth rate', sprintf('got %g, expected 1', solution.Objective));

% 5. SBtab round trip

components = rba_model_components_linear_pathway(kcat);
components_sbtab = rba_model_components_to_sbtab(components);
filename = [tempname '.tsv'];
sbtab_document_save(components_sbtab, filename);
components_2 = sbtab_to_rba_model_components(sbtab_document_load(filename));
delete(filename);
components_2.Parameter = components.Parameter;    % parameters are not exported yet
[~, f2] = build_and_solve(schema.metabolic_steady_state, components_2, 'vmet_R2');
n_failed = n_failed + report(abs(f2 - 1/sum(1./kcat)) < tol, 'SBtab round trip of model components', sprintf('got %g', f2));

% 6. LP format conversions

rba_model_indices     = rba_make_model_indices(schema.metabolic_steady_state, components);
rba_problem_numerical = rba_make_linear_problem_numerical(rba_make_linear_problem_symbolic(rba_model_indices), rba_model_indices);
roundtrip = lp_problem_to_lp_problem_numerical(lp_problem_numerical_to_lp_problem(rba_problem_numerical));
fn = fieldnames(rba_problem_numerical);
ok = all(cellfun(@(f) isequal(rba_problem_numerical.(f), roundtrip.(f)), fn));
n_failed = n_failed + report(ok, 'LP format round trip (linear-problem-numerical <-> rba_problem)', '');
compact = lp_problem_numerical_to_lp_problem_compact(rba_problem_numerical);
rba_problem_2 = lp_problem_compact_to_rba_problem(compact);
[~, solution] = rba(rba_problem_2, struct('method','LP_problem','LP_weight_vector', double(strcmp(compact.col_names,'vmet_R2'))));
n_failed = n_failed + report(abs(solution.Objective - 1/sum(1./kcat)) < tol, 'compact LP format, solved with rba.m', sprintf('got %g', solution.Objective));

if n_failed
  error('%d test(s) failed', n_failed);
else
  fprintf('All tests passed\n');
end


% ---------------------------------------------------------------

function [x, f] = build_and_solve(rba_model_schema, rba_model_components, id_opt)

warning_state = warning('off','rba_make_model_indices:unused_connections');
rba_model_indices     = rba_make_model_indices(rba_model_schema, rba_model_components);
warning(warning_state);
rba_problem_symbolic  = rba_make_linear_problem_symbolic(rba_model_indices);
rba_problem_numerical = rba_make_linear_problem_numerical(rba_problem_symbolic, rba_model_indices);
[x, f] = rba_linear_problem_solve(rba_problem_numerical, id_opt);

function failed = report(ok, name, message)

if ok
  fprintf('PASS  %s\n', name);
  failed = 0;
else
  fprintf('FAIL  %s  %s\n', name, message);
  failed = 1;
end
