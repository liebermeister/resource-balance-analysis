function [feasible, solution] = rba(rba_problem, options, p)

% [solution, rba_problem] = rba(rba_problem,options)
%
% Input:
% rba_problem:  rba_problem data struct (one of the two possible forms, see "help rba")
%               with ns state variables
%
% options.method           options: {'LP_problem', 'LP_problem_set_growth', 'screen_growth', 'maximise_growth'};
% options.LP_weight_vector [ns x 1] numerical weights for LP problem
% options.LP_type          type of LP problem {'maximise', 'minimise'}
% options.parameter        value of adjustable parameter (eg growth rate)
%                            o scalar; directly used in 'LP_problem_set_growth'
%                            o scalar; used as initial value in 'maximise_growth'
%                            o vector; used for 'screen_growth'
% options.verbose          0; 
%
% p: numerical parameter value, to override the setting "options.parameter"
%  
% Output:
%  feasible: Boolean o scalar for 'LP_problem', 'LP_problem_set_growth', 'maximise_growth'
%                    o vector for 'screen_growth'
%  solution: struct  o one struct for 'LP_problem', 'LP_problem_set_growth', 'maximise_growth'
%                    o list of structs for 'screen_growth'

%  
% TO DO: make the function more verbose  

% -------------------------------
% Initialise

eval(default('options','struct','p','[]'));
  
options_default.method = 'maximise_growth'; 
%{'LP_problem', 'LP_problem_set_growth'};
options_default.verbose          = 0; 
options_default.LP_weight_vector = [];
options_default.LP_type          = 'maximise'; % {'minimise'}
options_default.parameter        = 1;   % DESCRIBE!
options_default.parameter_min    = 0;   % DESCRIBE!
options_default.parameter_max    = 1;   % DESCRIBE!
options_default.parameter_step   = 0.2; % DESCRIBE!
options = join_struct(options_default,options);

% if parameter p is provided, override the setting in options
if p,
  options.parameter = p;
end

if length(options.parameter) > 1,
  if ~strcmp(options.method,'screen_growth'),
    warning('Parameter vector found; I switch to rba method "screen_growth"');
  end
  options.method = 'screen_growth';
end

opt = optimoptions('linprog','Display','none');

feasible = 1;
solution = struct;

% -------------------------------

switch options.method,
  
  case {'LP_problem', 'LP_problem_set_growth'},
    %% 'LP_problem': parameter-free RBA problem with fixed matrices
    %% 'LP_problem_set_growth': use matrices obtained from the given parameter value 
    
    if strcmp(options.method,'LP_problem_set_growth'),
      rba_problem.Constraints = rba_set_parameter_dependent_matrices(rba_problem.Constraints,options.parameter);
    end
    Aeq = rba_problem.Constraints.MatrixEq;
    A   = rba_problem.Constraints.MatrixIneq;
    beq = rba_problem.Constraints.VectorEq;
    b   = rba_problem.Constraints.VectorIneq;
    lb  = rba_problem.Variables.LowerBounds;
    ub  = rba_problem.Variables.UpperBounds;
    n_s = length(rba_problem.Variables.Names);
    z   = -ones(n_s,1);
    if options.LP_weight_vector, z = options.LP_weight_vector;  end
    if strcmp(options.LP_type,'maximise'), z = -z; end
    [x,f,exitflag] = linprog(z,A,b,Aeq,beq,lb,ub,opt);
    if exitflag~=1, 
      if options.verbose, warning('Optimisation unsuccessful'); end
      feasible=0;
    end
    if strcmp(options.LP_type,'maximise'), f = -f; end
    solution.StateVector = x;
    solution.Objective   = f;
  
  case 'screen_growth',
    % Run RBA for each of the parameter values in the vector options.parameter
    p                 = options.parameter;
    my_options        = options; 
    my_options.method = 'LP_problem_set_growth';
    for it = 1:length(p),
      [feasible(it), solution{it}] = rba(rba_problem,my_options,p(it));
    end    
  
  case 'maximise_growth',
    % Run dichotomy search to determine the maximal possible value of the parameter

    my_options        = options; 
    my_options.method = 'LP_problem_set_growth';
    p_lo              = 0;
    p_up              = options.parameter;
    
    if ~rba(rba_problem,my_options,p_lo),
      error('Problem is infeasible at parameter value = 0');
    end
    
    % setting the upper value = initial value;
    % then iteratively double the upper value until problem becomes infeasible
    feasible_up = rba(rba_problem,my_options,p_up);
    while feasible_up,
      p_up = 2 * p_up;
      feasible_up = rba(rba_problem,my_options,p_up);
    end

    %% dichotomy search: 
    % from now on, p_lo is known to be feasible and p_up is known to be infeasible
    while p_up > 1.000000001 * p_lo,
      if options.verbose,
        [p_lo p_up]
      end
      p_mid = 0.5 * [p_lo + p_up];
      feasible_mid = rba(rba_problem,my_options,p_mid);
      if feasible_mid, 
        p_lo = p_mid;
      else
        p_up = p_mid;
      end
    end

    if options.verbose, display('Dichotomy search finished successfully'); end
    
    % evaluate RBA problem one last time for the output
    [ff, solution]      = rba(rba_problem,my_options,p_lo);
    solution.Objective = p_lo;

end
