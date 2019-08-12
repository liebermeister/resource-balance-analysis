function rba_problem = rba_model_to_linear_problem(rba_model, rba_model_components)

% -----------------------------------------------------------------
% build field "linear_problem_symbolic" 
% for symbolic representation of the LP problem
% -----------------------------------------------------------------

variable_types = fieldnames(rba_model.variables);
nn             = length(variable_types);
st             = fieldnames(rba_model.statements);

LP_symbolic.variable_types      = variable_types;
LP_symbolic_variable_indices    = [];
LP_symbolic.x_lb                = repmat({'- Inf'},nn,1);
LP_symbolic.x_ub                = repmat({'+ Inf'},nn,1);
LP_symbolic.A{1,nn}             = [];
LP_symbolic.B{1,nn}             = [];
LP_symbolic.a                   = {};
LP_symbolic.b                   = {};
LP_symbolic.constraint_type_a   = [];
LP_symbolic.constraint_type_b   = [];
LP_symbolic.constraint_number_a = [];
LP_symbolic.constraint_number_b = [];

for it = 1:length(variable_types),
  LP_symbolic_variable_indices{it} = rba_model.variables.(variable_types{it}).indices;
end

it_eq   = 0;
it_ineq = 0;

for it = 1:length(st),

  my_statement       = rba_model.statements.(st{it});
  my_statement_type  = my_statement.StatementType;
  my_variable_type   = my_statement.Variable;
  my_variable_number = length(rba_model.variables.(my_variable_type).ids);
  it_variable_type   = rba_model.variables.(my_variable_type).variable_type_index;

  % simple cases: constraints involving only zeros or constants parameters on the right hand side
  
  switch my_statement_type,
    case 'is_equal_to_zero', 
      LP_symbolic.x_lb{it_variable_type,1} = '0';
      LP_symbolic.x_ub{it_variable_type,1} = '0';
    case 'is_lower_than_zero',
      LP_symbolic.x_ub{it_variable_type,1} = '0';
    case 'is_higher_than_zero',
      LP_symbolic.x_lb{it_variable_type,1} = '0';
    case 'is_equal_to_constant',
      LP_symbolic.x_lb{it_variable_type,1} = my_statement.RightHandSide;
      LP_symbolic.x_ub{it_variable_type,1} = my_statement.RightHandSide;
    case 'is_lower_than_constant',
      LP_symbolic.x_ub{it_variable_type,1} = my_statement.RightHandSide;
    case 'is_higher_than_constant',
      LP_symbolic.x_lb{it_variable_type,1} = my_statement.RightHandSide;
    case 'is_equal_to_variable',
      %% replace "x = y" by "x = + I * y" 
      my_constraint_type = ['eq_' my_variable_type '_equal_to'];
      new_statement = struct;
      new_statement.StatementType = 'is_given_by_formula';
      my_rhs_sign = my_statement.RightHandSideSign;
      switch my_rhs_sign,
        case '+', 
          new_statement.RightHandSide.(my_statement.RightHandSide) = '+ I';
        case '-', 
          new_statement.RightHandSide.(my_statement.RightHandSide) = '- I';
      end
      new_statement.Operator = '==';
      my_statement = new_statement;
    case 'is_higher_than_variable',
      %% replace "x >= y" by "x >= + I * y" 
      my_constraint_type = ['ineq_' my_variable_type '_higher_than_' my_statement.RightHandSide];
      new_statement = struct;
      new_statement.StatementType = 'is_given_by_formula';
      my_rhs_sign = my_statement.RightHandSideSign;
      switch my_rhs_sign,
        case '+', 
          new_statement.RightHandSide.(my_statement.RightHandSide) = '+ I';
        case '-', 
          new_statement.RightHandSide.(my_statement.RightHandSide) = '- I';
      end
      new_statement.Operator = '>=';
      my_statement = new_statement;
    case 'is_lower_than_variable',
      %% replace "x <= y" by "x <= + I * y" 
      my_constraint_type = ['ineq_' my_variable_type '_lower_than_' my_statement.RightHandSide];
      new_statement = struct;
      new_statement.StatementType = 'is_given_by_formula';
      my_rhs_sign = my_statement.RightHandSideSign;
      switch my_rhs_sign,
        case '+', 
          new_statement.RightHandSide.(my_statement.RightHandSide) = '+ I';
        case '-', 
          new_statement.RightHandSide.(my_statement.RightHandSide) = '- I';
      end
      new_statement.Operator = '<=';
      my_statement = new_statement;
    case 'is_given_by',
      my_constraint_type = ['eq_' my_variable_type];% '_given_by'];
      my_statement.StatementType = 'is_given_by_formula';
      my_statement.Operator = '==';
    otherwise,
      error(sprintf('unsupported statement type %s', my_statement_type));
  end

  switch my_statement.StatementType,
    case 'is_given_by_formula',
      % matrix M, vector m
      m       = [];
      M       = {};
      M{1,nn} = [];
      M{1,it_variable_type} = '- I';
      fnn = fieldnames(my_statement.RightHandSide);
      for itt = 1:length(fnn),
        my_input_variable      = fnn{itt};
        my_connection_matrix   = my_statement.RightHandSide.(fnn{itt});
        it_input_variable_type = rba_model.variables.(my_input_variable).variable_type_index;
        M{1,it_input_variable_type} = my_connection_matrix;
      end
      switch my_statement.Operator,
        case '==',
          it_eq = it_eq + 1;
          LP_symbolic.A(it_eq,:)                    = M;
          LP_symbolic.a{it_eq,1}                    = m;
          LP_symbolic.constraint_type_a{it_eq,1}    = my_constraint_type;
          LP_symbolic.constraint_number_a(it_eq,1)  = my_variable_number;
        case {'<='},
          %% swap signs of M and m
          m = symbolic_switch_sign(m);
          for it = 1:length(M)
            M{it} = symbolic_switch_sign(M{it});
          end
          it_ineq = it_ineq + 1;
          LP_symbolic.B(it_ineq,:)                    = M;
          LP_symbolic.b{it_ineq,1}                    = m;
          LP_symbolic.constraint_type_b{it_ineq,1}    = my_constraint_type;
          LP_symbolic.constraint_number_b(it_ineq,1)  = my_variable_number;
        case {'>='},
          it_ineq = it_ineq + 1;
          LP_symbolic.B(it_ineq,:)                    = M;
          LP_symbolic.b{it_ineq,1}                    = m;
          LP_symbolic.constraint_type_b{it_ineq,1}    = my_constraint_type;
          LP_symbolic.constraint_number_b(it_ineq,1)  = my_variable_number;
      end
  end
  
end

rba_problem.symbolic = LP_symbolic;


% -----------------------------------------------------------------
% build field "linear_problem_numeric" 
% for numerical representation of the LP problem
% -----------------------------------------------------------------

x_id = [];
x_lb = [];
x_ub = [];
a_id = [];
b_id = [];
A    = [];
a    = [];
B    = [];
b    = [];

n_x = 0;

% collect ids and bounds for all variables x in x_id, x_lb, and x_ub

for it = 1:length(LP_symbolic.variable_types),
  my_x_type    = LP_symbolic.variable_types{it};
  my_x_indices = rba_model.variables.(my_x_type).ids;
  my_x_n       = length(my_x_indices);
  n_x          = n_x + my_x_n;
  my_x_lb_symbolic = LP_symbolic.x_lb{it};
  my_x_ub_symbolic = LP_symbolic.x_ub{it};
  my_x_id      = rba_model.variables.(my_x_type).ids;
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
  x_id         = [x_id; my_x_id];
  x_lb         = [x_lb; my_x_lb];
  x_ub         = [x_ub; my_x_ub];
end

% compute the matrix A and vector a (for equality constraints)

for it = 1:length(LP_symbolic.constraint_type_a),
  my_constraint_type   = LP_symbolic.constraint_type_a{it};
  my_constraint_number = LP_symbolic.constraint_number_a(it);
  my_a_id              = numbered_names(my_constraint_type,my_constraint_number,0);
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
        otherwise, error('Term in in RBA dependency formula must have the form "[sign] [matrixname]"');
      end          
      my_vector_string = my_rhs_string(3:end);
      my_a = rba_model.parameters.(my_vector_string);
  end
  my_A_row = zeros(length(my_a),n_x);
  for itt = 1:length(LP_symbolic.variable_types)
    my_x_type = LP_symbolic.variable_types{itt};
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
        otherwise, error('Term in in RBA dependency formula must have the form "[sign] [matrixname]"');
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
  a_id = [a_id; my_a_id];
  A    = [A; my_A_row];
end

% compute the matrix B and vector b (for equality constraints)

for it = 1:length(LP_symbolic.constraint_type_b),
  my_constraint_type   = LP_symbolic.constraint_type_b{it};
  my_constraint_number = LP_symbolic.constraint_number_b(it);
  my_b_id              = numbered_names(my_constraint_type,my_constraint_number,0);
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
        otherwise, error('Term in in RBA dependency formula must have the form "[sign] [matrixname]"');
      end          
      my_vector_string = my_rhs_string(3:end);
      my_b = rba_model.parameters.(my_vector_string);
  end
  my_B_row = zeros(length(my_b),n_x);
  for itt = 1:length(LP_symbolic.variable_types)
    my_x_type = LP_symbolic.variable_types{itt};
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
        otherwise, error('Termin in RBA dependency formula must have the form "[sign] [matrixname]"');
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
  b_id = [b_id; my_b_id];
  B    = [B; my_B_row];
end

rba_problem.numeric = struct;

rba_problem.numeric.x_id    = x_id;
rba_problem.numeric.a_eq_id = a_id; % numbered_names('a',length(a),0);
rba_problem.numeric.b_in_id = b_id; % numbered_names('b',length(b),0);
rba_problem.numeric.x_lb    = x_lb;
rba_problem.numeric.x_ub    = x_ub;
rba_problem.numeric.A_eq    = sparse(A);
rba_problem.numeric.a_eq    = a;
rba_problem.numeric.B_in    = sparse(B);
rba_problem.numeric.b_in    = b;


% ===============================================

function formula = symbolic_switch_sign(formula)

if length(formula),
  formula = ['- ', formula];
  formula = strrep(formula,'- - ','+ ');
  formula = strrep(formula,'- + ','- ');
end
