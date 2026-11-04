function [x, fval, exitflag, output, lambda] = rba_linprog(f, A, b, Aeq, beq, lb, ub)

% [x, fval, exitflag, output, lambda] = rba_linprog(f, A, b, Aeq, beq, lb, ub)
%
% Wrapper for linprog (minimise f' * x subject to A x <= b, Aeq x == beq, lb <= x <= ub),
% used by all RBA functions. It uses linprog's default algorithm; if this throws an error
% (e.g. the HiGHS dual simplex in some MATLAB R2025b installations fails with
% 'Unrecognized field name "optimstatus"'), it falls back to the interior-point algorithm.

persistent use_fallback

opt = optimoptions('linprog','Display','off');

if isempty(use_fallback) || ~use_fallback
  try
    [x, fval, exitflag, output, lambda] = linprog(f, A, b, Aeq, beq, lb, ub, opt);
    return
  catch err
    warning('rba_linprog:fallback', 'linprog with default algorithm failed (%s); using interior-point algorithm from now on', err.message);
    use_fallback = true;
  end
end

opt = optimoptions('linprog','Display','off','Algorithm','interior-point');
[x, fval, exitflag, output, lambda] = linprog(f, A, b, Aeq, beq, lb, ub, opt);
