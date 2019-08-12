function rba_linear_problem_symbolic_display(rba_problem_symbolic,style)

% rba_linear_problem_symbolic_display(rba_problem_symbolic,style)
%
% Display RBA optimality problem (symbolic)
%
% 'rba_problem_numeric' is output of matlab function 'rba_model_to_linear_problem_symbolic'
% 'style' = ( 'matrices' | 'equations' )
  
eval(default('style','''equations'''))
  
switch style,
  case 'matrices',

% display [A,a] as matrix
display('Matrix [A|a]')
[ {''}, rba_problem_symbolic.variable_types', {''}; rba_problem_symbolic.constraint_types_a, rba_problem_symbolic.A, rba_problem_symbolic.a]

% display [B,b] as matrix

display('Matrix [B|b]')
[ {''}, rba_problem_symbolic.variable_types', {''}; rba_problem_symbolic.constraint_types_b, rba_problem_symbolic.B, rba_problem_symbolic.b]

  case 'equations',

display(sprintf('Equalities\n'));

for it = 1:length(rba_problem_symbolic.a)
  display(rba_problem_symbolic.constraint_types_a{it})
  ind = find(cellfun('length',rba_problem_symbolic.A(it,:)));
  display(mytable([rba_problem_symbolic.A(it,ind)', repmat({'*'},length(ind),1), rba_problem_symbolic.variable_types(ind)],0))
end

display(sprintf('Inequalities\n'));

for it = 1:length(rba_problem_symbolic.b)
  display(rba_problem_symbolic.constraint_types_b{it})
  ind = find(cellfun('length',rba_problem_symbolic.B(it,:)));
  display(mytable([rba_problem_symbolic.B(it,ind)', repmat({'*'},length(ind),1), rba_problem_symbolic.variable_types(ind)],0))
end

end