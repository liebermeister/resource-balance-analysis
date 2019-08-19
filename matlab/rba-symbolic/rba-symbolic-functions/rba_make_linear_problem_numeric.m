function rba_problem_numeric = rba_make_linear_problem_numeric(rba_problem_symbolic, rba_model, rba_model_components)

% rba_problem_numeric = rba_make_linear_problem_numeric(rba_problem_symbolic, rba_model, rba_model_components)
%
% translate 'rba_problem_symbolic' into 'rba_problem_numeric' struct, using information from 'rba_model', and 'rba_model_components' structs
% 
% for data structure 'rba_problem_numeric', see 'help rba-symbolic'
%
% the function uses bounds and connection matrices from 'rba_model_components'

  
LP_symbolic = rba_problem_symbolic;

for it = 1:length(LP_symbolic.constrained_variable_a),
  my_variable_type = LP_symbolic.constrained_variable_a{it}; 
  my_variable_number = length(rba_model.variables.(my_variable_type).ids);
  constraint_numbers_a(it) = my_variable_number;
end

for it = 1:length(LP_symbolic.constrained_variable_b),
  my_variable_type = LP_symbolic.constrained_variable_b{it}; 
  my_variable_number = length(rba_model.variables.(my_variable_type).ids);
  constraint_numbers_b(it) = my_variable_number;
end

% -----------------------------------------------------------------
% build field "linear_problem_numeric" 
% for numerical representation of the LP problem
% -----------------------------------------------------------------

id_x = [];
id_a = [];
id_b = [];
x_lb = [];
x_ub = [];
A    = [];
a    = [];
B    = [];
b    = [];

n_x = 0;

% collect ids and bounds for all variables x in id_x, x_lb, and x_ub

for it = 1:length(LP_symbolic.names_x),
  my_x_type    = LP_symbolic.names_x{it};
  my_x_indices = rba_model.variables.(my_x_type).ids;
  my_x_n       = length(my_x_indices);
  n_x          = n_x + my_x_n;
  my_x_lb_symbolic = LP_symbolic.x_lb{it};
  my_x_ub_symbolic = LP_symbolic.x_ub{it};
  my_id_x      = rba_model.variables.(my_x_type).ids;
  my_x_ub      = nan * ones(my_x_n,1);
  switch my_x_lb_symbolic,
    case '0',     my_x_lb = zeros(my_x_n,1);
    case '- inf', my_x_lb = -inf * ones(my_x_n,1);
    otherwise,    my_x_lb = nan * ones(my_x_n,1);
  end
  switch my_x_ub_symbolic,
    case '0',     my_x_ub = zeros(my_x_n,1);
    case 'inf',   my_x_ub = inf * ones(my_x_n,1);
    otherwise,    my_x_ub = nan * ones(my_x_n,1);
  end
  %% join the bounds required by the scheme with bounds given in
  %% model-components, by using the stricter value in each case
  my_x_lb      = max([my_x_lb, rba_model_components.variables.(my_x_type).LowerBound],[],2);
  my_x_ub      = min([my_x_ub, rba_model_components.variables.(my_x_type).UpperBound],[],2);
  id_x         = [id_x; my_id_x];
  x_lb         = [x_lb; my_x_lb];
  x_ub         = [x_ub; my_x_ub];
end

% compute the matrix A and vector a (for equality constraints)

for it = 1:length(LP_symbolic.names_a),
  my_constraint_type   = LP_symbolic.names_a{it};
  my_constraint_number =constraint_numbers_a(it);
  my_id_a              = numbered_names(my_constraint_type,my_constraint_number,0);
  my_rhs_string        = LP_symbolic.a{it};
  if isempty(my_rhs_string),
    my_rhs_string = '0';
  end
  switch my_rhs_string,
    case '0',
      my_a = zeros(my_constraint_number,1);
    otherwise
      my_sign_string = my_rhs_string(1:2);
      switch(my_sign_string),
        case '+ ', my_sign = 1;
        case '- ', my_sign = -1;
        otherwise, error('Term in RBA dependency formula must have the form "[sign] [matrixname]"');
      end          
      my_vector_string = my_rhs_string(3:end);
      my_a = rba_model.parameters.(my_vector_string);
  end
  my_A_row = zeros(length(my_a),n_x);
  for itt = 1:length(LP_symbolic.names_x)
    my_x_type = LP_symbolic.names_x{itt};
    my_x_indices = rba_model.variables.(my_x_type).indices;
    my_x_n = length(my_x_indices);
    my_block_string = LP_symbolic.A{it,itt};
    if strcmp(my_block_string,'0'),
      my_block_string = [];
    end
    if length(my_block_string),
      my_sign_string = my_block_string(1:2);
      switch(my_sign_string),
        case '+ ', my_sign = 1;
        case '- ', my_sign = -1;
        otherwise, error('Term in RBA dependency formula must have the form "[sign] [matrixname]"');
      end          
      my_matrix_string = my_block_string(3:end);
      switch my_matrix_string,
        case 'I',
          my_block = my_sign * eye(my_x_n);
        otherwise, 
          my_block = rba_model_components.connections.(my_matrix_string);
      end
      my_A_row(:,my_x_indices) = my_block;
    end
  end
  a    = [a; my_a];
  id_a = [id_a; my_id_a];
  A    = [A; my_A_row];
end

% compute the matrix B and vector b (for equality constraints)

for it = 1:length(LP_symbolic.names_b),
  my_constraint_type   = LP_symbolic.names_b{it};
  my_constraint_number =constraint_numbers_b(it);
  my_id_b              = numbered_names(my_constraint_type,my_constraint_number,0);
  my_rhs_string        = LP_symbolic.b{it};
  if isempty(my_rhs_string),
    my_rhs_string = '0';
  end
  switch my_rhs_string,
    case '0',
      my_b = zeros(my_constraint_number,1);
    otherwise
      my_sign_string = my_rhs_string(1:2);
      switch(my_sign_string),
        case '+ ', my_sign = 1;
        case '- ', my_sign = -1;
        otherwise, error('Term in RBA dependency formula must have the form "[sign] [matrixname]"');
      end          
      my_vector_string = my_rhs_string(3:end);
      my_b = rba_model.parameters.(my_vector_string);
  end
  my_B_row = zeros(length(my_b),n_x);
  for itt = 1:length(LP_symbolic.names_x)
    my_x_type = LP_symbolic.names_x{itt};
    my_x_indices = rba_model.variables.(my_x_type).indices;
    my_x_n = length(my_x_indices);
    my_block_string = LP_symbolic.B{it,itt};
    if strcmp(my_block_string,'0'),
      my_block_string = [];
    end
    if length(my_block_string),
      my_sign_string = my_block_string(1:2);
      switch(my_sign_string),
        case '+ ', my_sign = 1;
        case '- ', my_sign = -1;
        otherwise, error('Term in RBA dependency formula must have the form "[sign] [matrixname]"');
      end          
      my_matrix_string = my_block_string(3:end);
      switch my_matrix_string,
        case 'I', 
          my_block = my_sign * eye(my_x_n);
        otherwise, 
          my_block = rba_model_components.connections.(my_matrix_string);
      end
      my_B_row(:,my_x_indices) = my_block;
    end
  end

  b    = [b; my_b];
  id_b = [id_b; my_id_b];
  B    = [B; my_B_row];
end

rba_problem_numeric = struct;

rba_problem_numeric.id_x = id_x;
rba_problem_numeric.id_a = id_a; % numbered_names('a',length(a),0);
rba_problem_numeric.id_b = id_b; % numbered_names('b',length(b),0);
rba_problem_numeric.x_lb = x_lb;
rba_problem_numeric.x_ub = x_ub;
rba_problem_numeric.A    = sparse(A);
rba_problem_numeric.a    = a;
rba_problem_numeric.B    = sparse(B);
rba_problem_numeric.b    = b;
