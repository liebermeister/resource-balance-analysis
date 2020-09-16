% DEMO

rba_simple_test_model; 
% -> defines RBA problem in data structure "rba_problem"
[~,solution] = rba(rba_problem,struct('method', 'maximise_growth')); 
solution.StateVector

% works, but is very slow; ask oliver for smaller models?

% file = '/home/wolfram/projekte/rba/matlab/rba-value-structure/data/MatricesOfRBA.mat';
% rba_LP_problem = rba_linear_problem_from_matfile(file);
% [feasible,solution] = rba(rba_LP_problem);
% 
% file1 = '/home/wolfram/projekte/rba/matlab/rba-value-structure/data/MatricesOfRBA.mat';
% file2 = '/home/wolfram/projekte/rba/matlab/rba-value-structure/data/MatricesOfRBA_minus1%.mat';
% rba_growth_problem = rba_growth_problem_from_matfiles(file1,file2);
% [feasible, solution, rba_growth_problem] = rba(rba_growth_problem,struct('method','LP_problem_set_growth','growth',1));
% [feasible, solution] = rba(rba_growth_problem,struct('method','maximise_growth','growth',1));
  
