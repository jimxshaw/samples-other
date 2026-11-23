
% ================ PREDICATES ================ %

% 3. subslice(+List1, +List2): true if List1 appears as a contiguous
% run of elements anywhere in List2.
% Try every suffix of List2; succeed if one starts with List1.
% once/1 stops after the first match since this is a yes/no test.
subslice(Sub, List) :-
    once((
        append(_, Suffix, List),
        append(Sub, _, Suffix)
    )).

% 5. luhn(+Integer): true if Number passes the Luhn checksum.
% Walk digits right to left, doubling every 2nd digit (a doubled
% 2-digit result has its digits added). Valid if the total ends in 0.
luhn(Number) :-
    integer(Number),
    Number >= 0,
    luhn_sum(Number, false, Sum),
    Sum mod 10 =:= 0.

% luhn_sum(+Remaining, +ShouldDouble, -Sum): total of the Luhn digit values.
luhn_sum(Remaining, ShouldDouble, Sum) :-
    (   Remaining =:= 0
    ->  Sum = 0
    ;   Digit is Remaining mod 10,
        Rest is Remaining // 10,
        luhn_digit_value(ShouldDouble, Digit, Value),
        luhn_flip(ShouldDouble, NextShouldDouble),
        luhn_sum(Rest, NextShouldDouble, RestSum),
        Sum is Value + RestSum
    ).

% luhn_digit_value(+ShouldDouble, +Digit, -Value)
% Flag comes first so Prolog picks the right clause without a choicepoint.
luhn_digit_value(false, Digit, Digit).
luhn_digit_value(true, Digit, Value) :-
    Doubled is Digit * 2,
    Value is Doubled // 10 + Doubled mod 10.

% luhn_flip(+Flag, -Flipped)
luhn_flip(true, false).
luhn_flip(false, true).




% ================ TESTS ================ %
% Run with: ?- run_tests.

% Subslice tests %
:- begin_tests(subslice).

test(middle) :- subslice([2,3,4], [1,2,3,4]).
test(inner) :- subslice([8,13], [3,4,8,13,7]).
test(missing, [fail]) :- subslice([3], [1,2,4]).
test(empty_sub) :- subslice([], [1,2,4]).
test(empty_list, [fail]) :- subslice([1,2,4], []).
test(whole_list) :- subslice([1,2,4], [1,2,4]).
test(at_end) :- subslice([4,5], [1,2,4,5]).
test(appears_twice) :- subslice([1], [1,2,1]).
test(not_contiguous, [fail]) :- subslice([1,3], [1,2,3]).
test(both_empty) :- subslice([], []).

:- end_tests(subslice).

% Luhn tests %
:- begin_tests(luhn).

test(valid_long) :- luhn(799273987104).
test(valid_spec) :- luhn(49927398716).
test(valid_short) :- luhn(59).
test(invalid_spec, [fail]) :- luhn(49927398717).
test(invalid_other, [fail]) :- luhn(79927398710).
test(not_integer, [fail]) :- luhn(abc).

:- end_tests(luhn).

