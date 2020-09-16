function rba_problem_symbolic = rba_make_linear_problem_symbolic(rba_model_indices, rba_model_components)

% rba_problem_symbolic = rba_make_linear_problem_symbolic(rba_model_indices, rba_model_components)
%
% build 'rba_problem_symbolic' struct from rba_model_indices and 'rba_model_components' structs
% 
% for data structure 'rba_problem_symbolic', see 'help rba-symbolic'
%
% uses bounds and connection matrices from 'rba_model_components'
%
% Note the variable names A, a, B, b denoting constraints
%  A x == a
%  B x <= b
%
% -----------------------------------------------------------------
% build field "linear_problem_symbolic" 
% for symbolic representation of the LP problem
% -----------------------------------------------------------------

names_x = fieldnames(rba_model_indices.variables);
nn      = length(names_x);
st      = fieldnames(rba_model_indices.statements);

LP_symbolic.names_x             = names_x;
LP_symbolic.names_a             = [];
LP_symbolic.names_b             = [];
LP_symbolic.x_lb                = repmat({'- Inf'},nn,1);
LP_symbolic.x_ub                = repmat({'+ Inf'},nn,1);
LP_symbolic.A{1,nn}             = [];
LP_symbolic.B{1,nn}             = [];
LP_symbolic.a                   = {};
LP_symbolic.b                   = {};
LP_symbolic.constrained_variable_a = [];
LP_symbolic.constrained_variable_b = [];

it_eq   = 0;
it_ineq = 0;

for it = 1:length(st),

  my_statement       = rba_model_indices.statements.(st{it});
  my_statement_type  = my_statement.StatementType;
  my_variable_type   = my_statement.Variable;
  my_variable_number = length(rba_model_indices.variables.(my_variable_type).ids);
  it_variable_type   = rba_model_indices.variables.(my_variable_type).variable_type_index;

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
      new_statement.StatementType = 'given_by_formula';
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
      new_statement.StatementType = 'given_by_formula';
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
      new_statement.StatementType = 'given_by_formula';
      my_rhs_sign = my_statement.RightHandSideSign;
      switch my_rhs_sign,
        case '+', 
          new_statement.RightHandSide.(my_statement.RightHandSide) = '+ I';
        case '-', 
          new_statement.RightHandSide.(my_statement.RightHandSide) = '- I';
      end
      new_statement.Operator = '<=';
      my_statement = new_statement;
    case 'given_by',
      my_constraint_type = ['eq_' my_variable_type];% '_given_by'];
      my_statement.StatementType = 'given_by_formula';
      my_statement.Operator = '==';
    otherwise,
      error(sprintf('unsupported statement type %s', my_statement_type));
  end

  switch my_statement.StatementType,
    case 'given_by_formula',
      % matrix M, vector m
      m       = [];
      M       = {};
      M{1,nn} = [];
      M{1,it_variable_type} = '- I';
      fnn = fieldnames(my_statement.RightHandSide);
      for itt = 1:length(fnn),
        my_input_variable      = fnn{itt};
        my_connection_matrix   = my_statement.RightHandSide.(fnn{itt});
        it_input_variable_type = rba_model_indices.variables.(my_input_variable).variable_type_index;
        M{1,it_input_variable_type} = my_connection_matrix;
      end
      switch my_statement.Operator,
        case '==',
          it_eq = it_eq + 1;
          LP_symbolic.A(it_eq,:)                    = M;
          LP_symbolic.a{it_eq,1}                    = m;
          LP_symbolic.names_a{it_eq,1}              = my_constraint_type;
          LP_symbolic.constrained_variable_a{it_eq,1} = my_variable_type;
        case {'<='},
          %% swap signs of M and m
          m = symbolic_switch_sign(m);
          for it = 1:length(M)
            M{it} = symbolic_switch_sign(M{it});
          end
          it_ineq = it_ineq + 1;
          LP_symbolic.B(it_ineq,:)                    = M;
          LP_symbolic.b{it_ineq,1}                    = m;
          LP_symbolic.names_b{it_ineq,1}    = my_constraint_type;
          LP_symbolic.constrained_variable_b{it_ineq,1}  = my_variable_type;
        case {'>='},
          it_ineq = it_ineq + 1;
          LP_symbolic.B(it_ineq,:)                    = M;
          LP_symbolic.b{it_ineq,1}                    = m;
          LP_symbolic.names_b{it_ineq,1}    = my_constraint_type;
          LP_symbolic.constrained_variable_b{it_ineq,1}  = my_variable_type;
      end
  end
  
end

rba_problem_symbolic = LP_symbolic;

function formula = symbolic_switch_sign(formula)

if length(formula),
  formula = ['- ', formula];
  formula = strrep(formula,'- - ','+ ');
  formula = strrep(formula,'- + ','- ');
end
