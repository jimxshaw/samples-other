
% ================ PREDICATES ================ %

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

:- begin_tests(luhn).

test(valid_long) :- luhn(799273987104).
test(valid_spec) :- luhn(49927398716).
test(valid_short) :- luhn(59).
test(invalid_spec, [fail]) :- luhn(49927398717).
test(invalid_other, [fail]) :- luhn(79927398710).
test(not_integer, [fail]) :- luhn(abc).

:- end_tests(luhn).

