function rba_linear_problem_symbolic_display(LP_symbolic,style)

eval(default('style','''equations'''))
  
switch style,
  case 'matrices',

% display [A,a] as matrix
display('Matrix [A|a]')
[ {''}, LP_symbolic.variable_types', {''}; LP_symbolic.constraint_type_a, LP_symbolic.A, LP_symbolic.a]

% display [B,b] as matrix

display('Matrix [B|b]')
[ {''}, LP_symbolic.variable_types', {''}; LP_symbolic.constraint_type_b, LP_symbolic.B, LP_symbolic.b]

  case 'equations',

display(sprintf('Equalities\n'));

for it = 1:length(LP_symbolic.a)
  display(LP_symbolic.constraint_type_a{it})
  ind = find(cellfun('length',LP_symbolic.A(it,:)));
  display(mytable([LP_symbolic.A(it,ind)', repmat({'*'},length(ind),1), LP_symbolic.variable_types(ind)],0))
end

display(sprintf('Inequalities\n'));

for it = 1:length(LP_symbolic.b)
  display(LP_symbolic.constraint_type_b{it})
  ind = find(cellfun('length',LP_symbolic.B(it,:)));
  display(mytable([LP_symbolic.B(it,ind)', repmat({'*'},length(ind),1), LP_symbolic.variable_types(ind)],0))
end

end